namespace :craft do

  namespace :cache do
    task :clear do
      on release_roles(fetch(:craft_deploy_roles)) do
        craft_console "cache/flush"
      end
    end
  end

  namespace :assets do
    desc "Synchronise assets between local and remote server"
    task :sync do
      run_locally do
        on release_roles(fetch(:craft_deploy_roles)) do
          puts "User -> " + role.user
          execute :rsync, "-vzO #{role.user}@#{role.hostname}:#{shared_path}/web/assets/ web/assets"
          execute :rsync, "-vzO web/assets/ #{role.user}@#{role.hostname}:#{shared_path}/web/assets"
        end
      end
    end
  end
end