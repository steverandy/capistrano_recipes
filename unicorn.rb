set_default(:unicorn_config_path) { "#{current_path}/config/unicorn.rb" }
set_default(:unicorn_pid_path) { "#{current_path}/tmp/pids/unicorn.pid" }

namespace :unicorn do
  desc "Start Unicorn"
  task :start, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path} && BUNDLE_GEMFILE=#{current_path}/Gemfile bundle exec unicorn -c #{unicorn_config_path} -E production -D"
  end

  desc "Stop Unicorn gracefully"
  task :stop, :roles => :app, :except => {:no_release => true} do
    if remote_file_exists? unicorn_pid_path
      run "kill -s QUIT `cat #{unicorn_pid_path}`"
    else
      puts "Cannot stop Unicorn because pid file does not exist."
    end
  end

  desc "Restart Unicorn"
  task :restart, :roles => :app, :except => {:no_release => true} do
    unicorn.stop
    unicorn.start
  end

  desc "Restart Unicorn in rolling mode"
  task :rolling_restart, :roles => :app, :except => {:no_release => true} do
    if remote_file_exists? unicorn_pid_path
      run "kill -s USR2 `cat #{unicorn_pid_path}`"
    else
      start
    end
  end
end
