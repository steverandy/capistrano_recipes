namespace :nginx do
  desc "Install nginx from package"
  task :install do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install software-properties-common"
    run "#{sudo} add-apt-repository ppa:nginx/stable", :pty => true do |ch, stream, data|
      if data =~ /Press.\[ENTER\].to.continue/
        ch.send_data "\n"
      else
        Capistrano::Configuration.default_io_proc.call ch, stream, data
      end
    end
    run "#{sudo} apt-get -y install nginx"
  end
end
