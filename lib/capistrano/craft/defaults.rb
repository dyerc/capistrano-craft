#
# Craft CMS defaults
#

set :config_path, "config"

set :php, "php"

# console
set :craft_console_path, -> { "craft" }
set :craft_console_flags, ""

# Role filtering
set :craft_roles, :all
set :craft_deploy_roles, :all