# Capistrano Recipes

Sample code for deploy.rb:

    require "capistrano_colors"
    require "bundler/capistrano"
    require "whenever/capistrano"

    load "config/recipes/base"
    load "config/recipes/mongoid"
    load "config/recipes/unicorn"
    load "config/recipes/nginx"

    server "domain.com", :web, :app, :db, :primary => true

    set :domain, "domain.com"
    set :user, "user"
    set :group, "group"
    set :sudo_user, "admin"
    set :use_sudo, false
    set :application, "myapp"
    set :repository, "git@#{domain}:~/#{application}.git"
    set :scm, :git
    set :branch, "master"
    set :deploy_to, "/users/#{user}/rails"
    set :deploy_via, :remote_cache
    set :group_writable, false
    set :whenever_command, "bundle exec whenever"
    set :default_run_options, {:pty => true}
    set :ssh_options, {:forward_agent => true}
    set :default_environment, {"PATH" => "/usr/local/rbenv/shims:/usr/local/bin:$PATH"}
    set :symlink_shared_pairs, [
      ["#{shared_path}/sockets", "#{release_path}/tmp/"],
      ["#{shared_path}/config/mongoid.yml", "#{release_path}/config/"],
      ["#{shared_path}/config/mail.yml", "#{release_path}/config/"],
      ["#{shared_path}/config/backup.yml", "#{release_path}/config/"]
    ]
