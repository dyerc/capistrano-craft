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
    desc "Run the cache/flush Craft command"
    task :flush do
      on release_roles(fetch(:craft_deploy_roles)) do
        craft_console "cache/flush"
      end
    end
  end

  namespace :assets do
    desc "Synchronise assets between local and remote server"
    task :sync do
      run_locally do
        release_roles(fetch(:craft_deploy_roles)).each do |role|
          execute :rsync, "-rzO #{role.user}@#{role.hostname}:#{shared_path}/#{fetch(:assets_path)}/ #{fetch(:assets_path)}"
          execute :rsync, "-rzO #{fetch(:assets_path)}/ #{role.user}@#{role.hostname}:#{shared_path}/#{fetch(:assets_path)}"
        end
      end
    end
  end

  desc "Pull database and sync assets"
	task :pull do
		invoke "db:pull"
		invoke "craft:assets:sync"
	end

	desc "Push database and sync assets"
	task :push do
		invoke "db:push"
		invoke "craft:assets:sync"
  end
  
end