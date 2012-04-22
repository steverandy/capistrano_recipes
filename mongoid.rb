namespace :db do
  desc "Populate database with seed data."
  task :seed do
    run "cd #{current_path} && bundle exec rake db:seed RAILS_ENV=production"
  end

  desc "Create indexes of all models."
  task :create_indexes do
    run "cd #{current_path} && bundle exec rake db:mongoid:create_indexes RAILS_ENV=production"
  end
end
