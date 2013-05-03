_cset :assets_prefix, "assets"
_cset :shared_assets_prefix, "assets"
_cset :assets_role, [:web]

before "deploy:finalize_update", "deploy:assets:symlink"
after "deploy:update_code", "deploy:assets:precompile"

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => assets_role, :except => {:no_release => true} do
      run_locally "rake assets:clean && rake assets:precompile"
      run_locally "cd public && tar -jcf assets.tar.bz2 assets"
      top.upload "public/assets.tar.bz2", "#{shared_path}", :via => :scp
      run "cd #{shared_path} && tar -jxf assets.tar.bz2 && rm assets.tar.bz2"
      run_locally "rm public/assets.tar.bz2"
      run_locally "rake assets:clean"
    end

    task :symlink, :roles => assets_role, :except => {:no_release => true} do
      run <<-CMD.compact
        rm -rf #{latest_release}/public/#{assets_prefix} &&
        mkdir -p #{latest_release}/public &&
        mkdir -p #{shared_path}/#{shared_assets_prefix} &&
        ln -s #{shared_path}/#{shared_assets_prefix} #{latest_release}/public/#{assets_prefix}
      CMD
    end
  end
end
