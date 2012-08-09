set_default(:puma_pid_path) { "#{shared_path}/pids/puma.pid" }
set_default(:puma_socket_path) { "#{shared_path}/sockets/puma.sock" }

namespace :deploy do
  task :restart do
    puma.restart
  end
end

namespace :puma do
  desc "Restart Puma process"
  task :restart do
    if remote_file_exists?(puma_pid_path) && remote_file_exists?(puma_socket_path)
      run "kill -s USR2 `cat #{puma_pid_path}`"
    end
  end
end
