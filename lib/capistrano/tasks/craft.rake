namespace :craft do

  desc "Synchronise assets between local and remote server"
  task :sync_assets do
    run_locally do
      roles(:all) do |role|
        execute :rsync, "-vzO #{role.user}@#{role.hostname}:#{shared_path}/assets/ web/assets"
        execute :rsync, "-vzO web/assets/ #{role.user}@#{role.hostname}:#{shared_path}/assets"
      end
    end
  end
end