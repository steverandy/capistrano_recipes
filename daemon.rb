namespace :daemon do
  desc "Start daemon process for fetching mail."
  task :start do
    run "cd #{current_path} && bundle exec lib/daemons/mail_fetcher_ctl start"
  end

  desc "Stop daemon process for fetching mail."
  task :stop do
    run "cd #{current_path} && bundle exec lib/daemons/mail_fetcher_ctl stop"
  end

  desc "Restart daemon process for fetching mail."
  task :restart do
    stop
    start
  end
end
