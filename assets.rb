set_default(:assets_role) { [:web] }

before "deploy:finalize_update", "deploy:assets:symlink"
after "deploy:update_code", "deploy:assets:precompile"

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => assets_role, :except => {:no_release => true} do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ lib/assets/ app/assets/ | wc -l").to_i > 0
        run_locally "rake assets:clean && rake assets:precompile"
        run_locally "cd public && tar -jcf assets.tar.bz2 assets"
        top.upload "public/assets.tar.bz2", "#{shared_path}", :via => :scp
        run "cd #{shared_path} && tar -jxf assets.tar.bz2 && rm assets.tar.bz2"
        run_locally "rm public/assets.tar.bz2"
        run_locally "rake assets:clean"
      else
        logger.info "Skipping asset precompilation because there were no asset changes"
      end
    end

    task :symlink, roles: :web do
      run ("rm -rf #{latest_release}/public/assets && mkdir -p #{latest_release}/public && mkdir -p #{shared_path}/assets && ln -s #{shared_path}/assets #{latest_release}/public/assets")
    end
  end
end
