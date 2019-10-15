namespace :craft do
  namespace :db do
    desc "Download a backup of the remote database"
    task :backup do

    end

    namespace :local do
      desc "Export the local database to db.sql"
      task :backup do
        run_locally do
          postgres_dump("#{Dir.pwd}/.env", fetch(:craft_local_db_dump))
        end
      end
    end

    desc "Imports the local database into the remote server"
    task :push do
      # Save the remote database
      invoke 'craft:db:backup'

      # Save the local database
      invoke 'craft:db:local:backup'

      on release_roles(fetch(:craft_deploy_roles)) do
        # Upload local dump file
        uploaded_file = "#{fetch(:deploy_to)}/shared/db.sql"
        upload! fetch(:craft_local_db_dump), uploaded_file

        # Confirm
        # Are you sure you want to drop and recreate database: $DB_DATABASE? [y/N] 

        # Import into production
        execute SSHKit::Command.new <<-EOCOMMAND
          source "#{fetch(:deploy_to)}/shared/.env"
          PGPASSWORD=$DB_PASSWORD dropdb -U $DB_USER -h $DB_SERVER -p $DB_PORT $DB_DATABASE
          PGPASSWORD=$DB_PASSWORD createdb -U $DB_USER -h $DB_SERVER -p $DB_PORT $DB_DATABASE
          PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_DATABASE -h $DB_SERVER -p $DB_PORT -q < "#{uploaded_file}"
        EOCOMMAND

        # Remove temp file
        execute "rm #{uploaded_file}"
      end
    end
  end
end