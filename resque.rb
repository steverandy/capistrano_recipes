namespace :resque do
  desc "Start Resque process as a daemon"
  task :start do
    run "cd #{current_path} && bundle exec resque-pool --daemon --environment production"
  end

  desc "Stop Resque process gracefully by sending QUIT signal. All pending jobs will be compeleted before workers are killed."
  task :stop do
    if remote_file_exists? resque_pid
      run "kill -s QUIT `cat #{current_path}/tmp/pids/resque-pool.pid`"
    else
      puts "Cannot stop Resque because pid file does not exist."
    end
  end

  desc "Stop Resque process immediately by sending TERM signal. All pending jobs will be terminated immediately."
  task :force_stop do
    if remote_file_exists? resque_pid
      run "kill -s TERM `cat #{current_path}/tmp/pids/resque-pool.pid`"
    else
      puts "Cannot stop Resque because pid file does not exist."
    end
  end

  desc "Stop processing any new job without stopping Resque process by sending USR2 signal"
  task :stop_processing_job do
    if remote_file_exists? resque_pid
      run "kill -s USR2 `cat #{current_path}/tmp/pids/resque-pool.pid`"
    else
      puts "Cannot stop processing new job because pid file does not exist."
    end
  end

  desc "Restart Resque process by stopping the current process and start a new one. If no Resque process present, one will be started automatically. Before performing this task, it is a good idea to stop processing any new job by using the previous task."
  task :restart do
    stop
    sleep 5
    start
  end
end
