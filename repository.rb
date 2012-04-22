namespace :repository do
  desc "Create the remote Git repository."
  task :create do
    run "mkdir -p #{repository_path}"
    run "cd #{repository_path} && git --bare init"
    system "git remote rm origin"
    system "git remote add origin #{repository[:repository]}"
    puts "#{repository[:repository]} was added to your git repository as origin/master.\n"
  end

  desc "Destroy the remote Git repository."
  task :destroy do
    run "rm -rf #{repository_path}"
    system "git remote rm origin"
    puts "#{repository[:repository]} (origin/master) was removed from your git repository.\n".green
  end

  desc "Reset the remote Git repository."
  task :reset do
    destroy
    create
  end

  desc "Reinitialize origin/master."
  task :reinitialize do
    system "git remote rm origin"
    system "git remote add origin #{repository[:repository]}"
    puts "#{repository[:repository]} (origin/master) was added to your git repository.\n".green
  end
end
