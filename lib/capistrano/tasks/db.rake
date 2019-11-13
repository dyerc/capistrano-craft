namespace :db do
  namespace :local do
    desc "Export the local database (to db.sql by default)"
    task :backup do
      run_locally do
        database_dump(fetch(:craft_local_env), fetch(:craft_local_db_dump))
      end
    end

    desc "Import into the local database (from db.sql by default)"
    task :import do
      run_locally do
        database_restore(fetch(:craft_local_env), fetch(:craft_local_db_dump))
      end
    end
  end

  desc "Download a backup of the remote database"
  task :backup do
    on release_roles(fetch(:craft_deploy_roles)) do
      # Export remote dump file
      remote_backup_file = "#{fetch(:deploy_to)}/shared/db.sql"
      database_dump(fetch(:craft_remote_env), remote_backup_file)

      local_backup_file = backup_file_name
      download! remote_backup_file, local_backup_file

      # Remove temp file
      execute "rm #{remote_backup_file}"

      set :backup_filename, local_backup_file
    end
  end

  desc "Imports the remote database into the local environment"
  task :pull do
    invoke 'db:backup'

    run_locally do
      database_restore(fetch(:craft_local_env), fetch(:backup_filename))
    end
  end

  desc "Export the local database, overwriting the remote server"
  task :push do
    # Save the remote database
    invoke 'db:backup'

    # Save the local database
    invoke 'db:local:backup'

    on release_roles(fetch(:craft_deploy_roles)) do
      # Upload local dump file
      uploaded_file = "#{fetch(:deploy_to)}/shared/db.sql"
      upload! fetch(:craft_local_db_dump), uploaded_file

      confirm <<-EOF
Are you sure you want to drop and recreate the remote database?

A backup of the remote database has been taken in the file #{fetch(:backup_filename)} but you should verify this is correct before proceeding.
      EOF

      # Import into production
      database_restore(fetch(:craft_remote_env), uploaded_file)

      # Remove temp file
      execute "rm #{uploaded_file}"
    end
  end
end