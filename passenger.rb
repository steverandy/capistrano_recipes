namespace :passenger do
  desc "Restart Passenger process by creating restart.txt file."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
