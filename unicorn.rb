set_default(:unicorn_config) { "#{current_path}/config/unicorn.rb" }
set_default(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
set_default(:unicorn_socket) { "#{shared_path}/sockets/unicorn.sock" }

namespace :deploy do
  task :restart do
    unicorn.reload
  end
end

namespace :unicorn do
  desc "Start Unicorn process as a daemon."
  task :start do
    run "cd #{current_path} && BUNDLE_GEMFILE=#{current_path}/Gemfile bundle exec unicorn -c #{unicorn_config} -E production -D"
  end

  desc "Stop Unicorn process gracefully by sending QUIT signal. All pending requests will be completed before workers are killed."
  task :stop do
    if remote_file_exists? unicorn_pid
      run "kill -s QUIT `cat #{unicorn_pid}`"
    else
      puts "Cannot stop Unicorn because pid file does not exist."
    end
  end

  desc "Stop Unicorn process immediately by sending TERM signal. All pending request will be dropped immediately."
  task :force_stop do

    if remote_file_exists? unicorn_pid
      run "kill -s TERM `cat #{unicorn_pid}`"
    else
      puts "Cannot stop Unicorn because pid file does not exist."
    end
  end

  desc "Restart Unicorn process."
  task :restart do
    unicorn.stop
    unicorn.start
  end

  desc "Reload Unicorn process by sending USR2 signal, without droppping any pending requests. If no Unicorn process present, one will be started automatically."
  task :reload do
    if remote_file_exists? unicorn_pid
      run "kill -s USR2 `cat #{unicorn_pid}`"
    else
      start
    end
  end
end
