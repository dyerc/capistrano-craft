#
# Craft CMS defaults
#

append :linked_dirs, "vendor", "storage"

set :config_path, "config"
set :php, "php"

set :assets_path, "web/uploads"

set :craft_local_env, -> { "#{Dir.pwd}/.env" }
set :craft_remote_env, -> { "#{fetch(:deploy_to)}/shared/.env" }

set :craft_local_db_dump, "db.sql"
set :craft_local_backups, "backups"
set :craft_remote_backups, "shared/backups"

# assets
set :craft_compile_assets, "production"

# console
set :craft_console_path, -> { "craft" }
set :craft_console_flags, ""

# Role filtering
set :craft_roles, :all
set :craft_deploy_roles, :all