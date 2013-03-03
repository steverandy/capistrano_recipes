set_default(:ruby_version) { "1.9.3-p392" }

namespace :ruby do
  desc "Install ruby"
  task :install do
    run "#{sudo} apt-get -y install build-essential zlib1g zlib1g-dev libssl-dev libreadline-gplv2-dev libyaml-dev libmysqlclient-dev libcurl4-openssl-dev libxslt-dev libxml2-dev"
    run "cd /tmp"
    if ruby_version.match "1.9"
      ftp_path = "ftp://ftp.ruby-lang.org/pub/ruby/1.9"
    elsif ruby_version.match "2.0"
      ftp_path = "ftp://ftp.ruby-lang.org/pub/ruby/2.0"
    end
    run "wget #{ftp_path}/ruby-#{ruby_version}.tar.gz"
    run "tar -xvzf ruby-#{ruby_version}.tar.gz"
    run "cd ruby-#{ruby_version}/"
    run "./configure --prefix=/usr/local"
    run "make"
    run "make install"
    run "gem install bundler --no-ri --no-rdoc"
  end
end
