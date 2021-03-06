# Capistrano::Craft

This gem automates the deployment of Craft CMS apps with Capistrano. It will automatically detect local and remote environment settings to make synchronizing of database and assets straightforward.

- [x] Support for asset and database synchronization
- [x] Support for PostgreSQL databases
- [ ] Support for MySQL databases

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-craft'
```

Or install system wide:

    $ gem install capistrano-craft

## Usage

For a beginners guide to deploying your site (especially useful if you have little to no experience with Ruby) please see this blog article: https://cdyer.co.uk/blog/deploying-craft-cms-to-a-vps-server-with-capistrano

The setting you will likely need to customize is:
```
# This should be your command to compile assets for production
set :craft_compile_assets, true
set :craft_compile_assets_command, "npm install && npm run production --production --silent"
```

If you are using PHP-FPM it is necessary to restart it after deployment. Currently capistrano-craft doesn't handle this for you and you may need to add something along the lines of the following to your `deploy.rb` file.

```
before 'deploy:published', 'fpm_restart'

task :fpm_restart do
  on release_roles :all do |host|
    execute "sudo service php7.3-fpm restart"
  end
end
```

### Compiling Assets

Change `:craft_compile_assets_command` to be your production asset compilation command. By default, it is assumed your project has a `package.json` file and  `npm install` will be run first. The default asset compilcation command is `npm run production --production --silent`. You can disable asset compilation altogether by settng `:craft_compile_assets` to `false`.

### Synchronize Database


### Upgrading Craft CMS

When you deploy, Capistrano will run composer automatically installing your chosen packages. If you have upgraded Craft locally, the new version will automatically be installed on your deployment.

If you were to upgrade on the server, then run `cap production craft:pull` to sync the database and assets down, the database would be running a newer version than your local codebase. This should be easily resolved by updating through Composer or the Craft admin area (assuming Craft runs correctly with the conflict).

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
set :craft_compile_assets, true                                      
set :craft_compile_assets_command, "yarn install && yarn run production"

# console
set :craft_console_path, -> { "craft" }
set :craft_console_flags, ""

# Role filtering
set :craft_roles, :all
set :craft_deploy_roles, :all
```
