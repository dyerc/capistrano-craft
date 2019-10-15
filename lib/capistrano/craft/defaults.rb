#
# Craft CMS defaults
#

set :config_path, "config"

set :php, "php"

set :craft_local_db_dump, "db.sql"

set :craft_remote_backups, "shared/backups"

# console
set :craft_console_path, -> { "craft" }
set :craft_console_flags, ""

# Role filtering
set :craft_roles, :all
set :craft_deploy_roles, :all