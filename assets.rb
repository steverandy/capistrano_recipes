namespace :deploy do
  namespace :assets do
    desc "Run the precompile task locally and rsync with shared"
    task :precompile, :roles => assets_role, :except => {:no_release => true} do
      %x{bundle exec rake assets:precompile}
      %x{rsync --recursive --times --rsh=ssh --compress --human-readable --progress public/assets #{user}@#{host}:#{shared_path}}
      %x{bundle exec rake assets:clean}
    end
  end
end
