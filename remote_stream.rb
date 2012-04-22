namespace :remote_stream do
  desc "Stream production log."
  task :production_log do
    stream "tail -f #{shared_path}/log/production.log"
  end
end
