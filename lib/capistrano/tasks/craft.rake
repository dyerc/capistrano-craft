namespace :craft do

  desc "Ensure folder permissions are correct"
  task :set_permissions do
    on release_roles(fetch(:craft_deploy_roles)) do
      within release_path do
        # https://docs.craftcms.com/v3/installation.html#step-2-set-the-file-permissions

        execute "chmod 744 .env"
        execute "chmod 744 composer.json"
        execute "chmod 744 composer.lock"
        execute "chmod 744 config/license.key"
        execute "chmod -R 744 storage/*"
        execute "chmod -R 744 vendor/*"
        execute "chmod -R 744 web/cpresources/*"
      end
    end
  end

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

  desc "Pull database and sync assets"
	task :pull do
		invoke "db:pull"
		invoke "craft:sync_assets"
	end

	desc "Push database and sync assets"
	task :push do
		invoke "db:push"
		invoke "craft:sync_assets"
	end
end