set_default(:nginx_start_command) { "/usr/local/Cellar/nginx/1.0.8/sbin/nginx -c /usr/local/etc/nginx/nginx.conf" }
set_default(:nginx_stop_command) { "/usr/local/Cellar/nginx/1.0.8/sbin/nginx -s stop" }
set_default(:nginx_reload_command) { "/usr/local/Cellar/nginx/1.0.8/sbin/nginx -s reload" }
set_default(:nginx_pid_path) { "/usr/local/Cellar/nginx/1.0.8/logs/nginx.pid" }
set_default(:nginx_sites_enabled_path) { "/usr/local/etc/nginx/sites-enabled" }


namespace :nginx do
  desc "Start nginx."
  task :start do
    with_user(sudo_user) do
      run "#{sudo} #{nginx_start_command}"
    end
  end

  desc "Stop nginx."
  task :stop do
    with_user(sudo_user) do
      run "#{sudo} #{nginx_stop_command}"
    end
  end

  desc "Restart nginx."
  task :restart do
    nginx.stop
    nginx.start
  end

  desc "Reload nginx. If there is no nginx process present, then start it. Use when configuration file is modified."
  task :reload do
    unless remote_file_exists? nginx_pid_path
      nginx.start
    end
    with_user(sudo_user) do
      run "#{sudo} #{nginx_reload_command}"
    end
  end

  desc "Add nginx configuration and enable it."
  task :create do
    config = <<-CONFIG
upstream #{application}_app_server {
  server unix:#{unicorn_socket} fail_timeout=0;
}

server {
  listen 80;
  server_name www.#{domain};
  rewrite ^/(.*) http://#{domain}/$1 permanent;
}

server {
  listen 80;
  server_name #{domain} concen.#{domain};
  access_log logs/#{domain}.access.log main;
  client_max_body_size 30m;
  add_header X-UA-Compatible "IE=edge,chrome=1";
  root #{deploy_to}/current/public;

  try_files $uri/index.html $uri.html $uri @app;

  location ^~ /gridfs/ {
    proxy_ignore_headers Set-Cookie;
    proxy_hide_header Set-Cookie;
    proxy_cache all;
    proxy_pass http://#{application}_app_server;
  }

  location ~ ^/(assets)/  {
    root #{deploy_to}/current/public;
    expires max;
    add_header Cache-Control public;
  }

  location @app {
    # proxy_set_header X-Forwarded-Proto https; # Enable this if and only if you use HTTPS.
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_ignore_headers Set-Cookie;
    proxy_cache all;
    proxy_pass http://#{application}_app_server;
  }

  location @503 {
    error_page 405 = /system/maintenance.html;
    if (-f $request_filename) {
      break;
    }
    rewrite ^(.*)$ /system/maintenance.html break;
  }

  if (-f $document_root/system/maintenance.html) {
    return 503;
  }

  error_page 404 /404.html;
  error_page 500 502 504 /500.html;
  error_page 503 @503;
}

CONFIG

    create_tmp_file(config, domain)
    with_user(sudo_user) do
      run "#{sudo} mkdir -p #{nginx_sites_enabled_path}"
      run "#{sudo} rm #{nginx_sites_enabled_path}/#{domain}"
      top.upload "tmp/#{domain}", "#{nginx_sites_enabled_path}/", :via => :scp
      run "#{sudo} chown #{user}:#{group} #{nginx_sites_enabled_path}/#{domain}"
    end
    File.delete("tmp/#{domain}")
    nginx.reload
  end

  desc "Remove nginx configuration and disable it."
  task :destroy do
    run "rm #{nginx_sites_enabled_path}/#{domain}"
    nginx.reload
  end

  desc "Purge nginx proxy cache by removing its cache directory."
  task :purge_cache do
    with_user(sudo_user) do
      run "#{sudo} rm -r /usr/local/var/nginx/cache/all"
      run "#{sudo} mkdir /usr/local/var/nginx/cache/all"
      run "#{sudo} chown nobody /usr/local/var/nginx/cache/all"
    end
    nginx.restart
  end
end
