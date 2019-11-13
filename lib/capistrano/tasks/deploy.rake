namespace :deploy do
  task :updating do
    invoke "craft:set_permissions"
  end

  desc 'Compile assets'
  task :compile_assets do
    on release_roles(fetch(:craft_deploy_roles)) do
      within release_path do
        execute :yarn, "install"
        execute :yarn, "run", fetch(:craft_compile_assets)
      end
    end
  end

  after 'deploy:updated', 'deploy:compile_assets'
  after 'deploy:finished', 'craft:cache:clear'
end