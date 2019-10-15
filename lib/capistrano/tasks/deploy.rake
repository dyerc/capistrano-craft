namespace :deploy do
  task :updating do
    invoke "craft:set_permissions"
  end
end