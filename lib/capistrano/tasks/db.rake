namespace :craft do
  namespace :db do
    desc "Download a backup of the remote database"
    task :backup do

    end

    desc "Imports the local database into the remote server"
    task :push do
      on release_roles(fetch(:craft_deploy_roles)) do
        run_locally do
          execute <<-EOBLOCK
            SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")"
            CRAFT_DIR="$(dirname "$SCRIPTS_DIR")"
            
            source "${CRAFT_DIR}/.env"
            
            PGPASSWORD=$DB_PASSWORD
            pg_dump -U $DB_USER -F p $DB_DATABASE > "${CRAFT_DIR}/db_rake.sql"
          EOBLOCK
        end
      end
    end
  end
end