namespace :remote do
  desc "Tail log" 
  task :log, :roles => :app, :only => {:primary => true} do
    run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}" 
      break if stream == :err
    end
  end

  desc "Start remote console"
  task :console, :roles => :app, :only => {:primary => true} do
    input = ""
    run "cd #{current_path} && bundle exec rails console #{rails_env}" do |channel, stream, data|
      next if data.chomp == input.chomp || data.chomp == ""
      print data
      channel.send_data(input = $stdin.gets) if data =~ /:\d{3}:\d+(\*|>)/
    end
  end
end
