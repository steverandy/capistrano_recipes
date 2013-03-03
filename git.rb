namespace :git do
  desc "Install git from package"
  task :install do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install git"
  end
end
