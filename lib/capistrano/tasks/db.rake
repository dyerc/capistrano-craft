namespace :db do
  namespace :local do
    desc "Export the local database to craft_local_db_dump (db.sql)"
    task :backup do
      run_locally do
        database_dump(fetch(:craft_local_env), fetch(:craft_local_db_dump))
      end
    end

    desc "Import into the local database from craft_local_db_dump (db.sql)"
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
      backup_file = "#{fetch(:deploy_to)}/shared/db.sql"
      database_dump(fetch(:craft_remote_env), backup_file)

      download! backup_file, backup_file_name

      # Remove temp file
      execute "rm #{backup_file}"

      set :backup_filename, backup_file_name
    end
  end

  desc "Imports the remote database into the local environment"
  task :pull do
    invoke 'db:backup'

    on release_roles(fetch(:craft_deploy_roles)) do
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