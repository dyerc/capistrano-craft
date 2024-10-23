namespace :craft do

  desc "Ensure folder permissions are correct"
  task :set_permissions do
    on release_roles(fetch(:craft_deploy_roles)) do
      # https://docs.craftcms.com/v3/installation.html#step-2-set-the-file-permissions

      # Attempt to chmod but don't fail if these aren't setup
      execute "chmod -f 744 #{fetch(:craft_remote_env)} || true"
      execute "chmod -f 744 #{release_path}/composer.json || true"
      execute "chmod -f 744 #{release_path}/composer.lock || true"
      execute "chmod -f 744 #{release_path}/config/license.key || true"
      execute "chmod -fR 744 #{release_path}/storage/* || true"
      execute "chmod -fR 744 #{release_path}/vendor/* || true"
      execute "chmod -fR 744 #{release_path}/web/cpresources/* || true"
    end
  end

  namespace :cache do
    desc "Run the clear-caches/all Craft command"
    task :clear do
      on release_roles(fetch(:craft_deploy_roles)) do
        craft_console "cache/flush-all"
        craft_console "clear-caches/all"
      end
    end
  end

  namespace :config do
    desc "Apply the project config to database after running Craft backup command"
    task :apply do
      on release_roles(fetch(:craft_deploy_roles)) do
        craft_console "db/backup --zip"
        craft_console "migrate/all --no-content"
        craft_console "project-config/apply"
        craft_console "migrate"
      end
    end
  end

  namespace :assets do
    desc "Synchronise assets between local and remote server"
    task :sync do
      invoke "craft:assets:pull"
      invoke "craft:assets:push"
    end

    desc "Download all assets from the remote server"
    task :pull do
      run_locally do
        release_roles(fetch(:craft_deploy_roles)).each do |role|
          execute :rsync, "-rzO #{role.user}@#{role.hostname}:#{shared_path}/#{fetch(:assets_path)}/ #{fetch(:assets_path)}"
        end
      end
    end

    desc "Upload all assets to the remote server"
    task :push do
      run_locally do
        release_roles(fetch(:craft_deploy_roles)).each do |role|
          execute :rsync, "-rzO #{fetch(:assets_path)}/ #{role.user}@#{role.hostname}:#{shared_path}/#{fetch(:assets_path)}"
        end
      end
    end

    desc "Re-indexes assets across all volumes"
    task :reindex do
      on release_roles(fetch(:craft_deploy_roles)) do
        craft_console "index-assets/all"
      end
    end
  end

  desc "Pull database and sync assets"
	task :pull do
		invoke "db:pull"
		invoke "craft:assets:pull"
	end

	desc "Push database and sync assets"
	task :push do
		invoke "db:push"
    invoke "craft:assets:push"
    invoke "craft:assets:reindex"
  end
  
end