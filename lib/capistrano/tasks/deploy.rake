namespace :deploy do
  task :updating do
    invoke "craft:set_permissions"
  end

  desc 'Compile assets'
  task :compile_assets do
    if fetch(:craft_compile_assets)
      on release_roles(fetch(:craft_deploy_roles)) do
        within release_path do
          execute fetch(:craft_compile_assets_command)
        end
      end
    end
  end

  after 'deploy:updated', 'deploy:compile_assets'
  after 'deploy:finished', 'craft:cache:clear'
end