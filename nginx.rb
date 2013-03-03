namespace :nginx do
  desc "Install latest stable release of nginx"
  task :install do
    run "#{sudo} add-apt-repository ppa:nginx/stable"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install nginx"
  end
end
