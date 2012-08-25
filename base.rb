def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

def create_tmp_file(contents, filename)
  system "mkdir tmp"
  file = File.new("tmp/#{filename}", "w")
  file << contents
  file.close
end

def remote_file_exists?(full_path)
  "true" == capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

def with_user(new_user, &block)
  old_user, old_pass = user, password
  set :user, new_user
  close_sessions
  yield
  set :user, old_user
  close_sessions
end

def close_sessions
  sessions.values.each { |session| session.close }
  sessions.clear
end

set_default(:symlink_shared_pair) { [] }

after "deploy:finalize_update", "deploy:symlink_shared"
after "deploy:restart", "deploy:set_releases_permissions"

namespace :deploy do
  desc "Symlink shared configs and folders on each release"
  task :symlink_shared do
    %w(config sockets system).each do |directory|
      unless remote_file_exists?("#{shared_path}/#{directory}")
        run "mkdir -p #{shared_path}/#{directory}"
      end
    end

    symlink_shared_pairs.each do |symlink_shared_pair|
      run "ln -nfs #{symlink_shared_pair[0]} #{symlink_shared_pair[1]}"
    end
  end

  desc "Set permissions for releases directory"
  task :set_releases_permissions do
    run "chmod -R go-rwx #{deploy_to}/releases/*"
    run "chmod go+rx #{current_path}"
    run "find #{current_path}/public -type d -exec chmod go+rx {} \\;"
    run "chmod -R go+r #{current_path}/public/*"
  end

  desc "Set permissions for shared directory"
  task :set_shared_permissions do
    run "chmod -R go-rwx #{deploy_to}/shared/*"
    run "chmod go+rx #{deploy_to}/shared"
    run "chmod go+rx #{deploy_to}/shared/sockets"
    run "chmod -R go+w #{deploy_to}/shared/sockets/*"
    run "chmod -R go+rx #{deploy_to}/shared/assets"
    run "chmod -R go+rx #{deploy_to}/shared/system"
    run "chmod -R go+rx #{deploy_to}/shared/videos"
  end

  desc "Run this for the first deploment"
  task :bootstrap, :roles => :web, :except => {:no_release => true} do
    setup; cold; restart; set_shared_permissions;
  end

  namespace :web do
    desc "Use this task to intercept all http request and show 503 maintenance page"
    task :disable, :roles => :web do
      on_rollback { rm "#{shared_path}/system/maintenance.html" }
      maintenance = File.read("./public/maintenance.html")
      put maintenance, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end

  namespace :assets do
    desc "Assets precompilation is only performed when any of the assets source file changed"
    task :precompile, :roles => :web, :except => {:no_release => true}, :only => {:primary => true} do
      releases_count = capture("find #{deploy_to}/releases/ -maxdepth 1 -mindepth 1 -type d | wc -l").to_i
      precompile = true
      paths = %w(app/assets/ lib/assets/ vendor/assets/ config/environments/production.rb)

      if releases_count > 1
        from = source.next_revision(current_revision)
        unless capture("cd #{latest_release} && #{source.local.log(from)} #{paths.join(' ')} | wc -l").to_i > 0
          precompile = false
          logger.info "Skipping asset pre-compilation because there were no asset changes"
        end
      end

      if precompile
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      end
    end
  end
end
