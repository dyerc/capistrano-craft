# Capistrano::Craft

As of October 2019 this is very still very much under development. Please make sure you have appropriate backups to avoid any potential data loss.

This gem automates the deployment of Craft CMS apps with Capistrano. It will automatically detect local and remote environment settings to make synchronizing of database and assets straightforward.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-craft'
```

Or install system wide:

    $ gem install capistrano-craft

## Usage

    $ staging deploy
    $ production deploy

### Compiling Assets

Change `:craft_compile_assets` to be your production asset compilation command. By default, it is assumed your project has a `package.json` file and  `npm install` will be run first. The default asset compilcation command is `npm run production --production --silent`

### Synchronize Database



### Settings




Full list of available settings:

```
set :config_path, "config"
set :php, "php"

set :craft_local_env, -> { "#{Dir.pwd}/.env" }
set :craft_remote_env, -> { "#{fetch(:deploy_to)}/shared/.env" }

set :craft_local_db_dump, "db.sql"
set :craft_local_backups, "backups"
set :craft_remote_backups, "shared/backups"

# assets
set :craft_compile_assets, "npm run production --production --silent"

# console
set :craft_console_path, -> { "craft" }
set :craft_console_flags, ""

# Role filtering
set :craft_roles, :all
set :craft_deploy_roles, :all
```
