#
# Craft CMS defaults
#

append :linked_dirs, "vendor", 
  "storage/backups", 
  "storage/composer-backups", 
  "storage/config-backups", 
  "storage/logs", 
  "storage/runtime"

set :config_path, "config"
set :php, "php"

set :assets_path, "web/uploads"

set :craft_local_env, -> { "#{Dir.pwd}/.env" }
set :craft_remote_env, -> { "#{fetch(:deploy_to)}/shared/.env" }

set :craft_local_db_dump, "db.sql"
set :craft_local_backups, "backups"
set :craft_remote_backups, "shared/backups"

# assets
set :craft_compile_assets, true
set :craft_compile_assets_command, "yarn install && yarn run production"

# console
set :craft_console_path, -> { "craft" }
set :craft_console_flags, ""

# Role filtering
set :craft_roles, :all
set :craft_deploy_roles, :all