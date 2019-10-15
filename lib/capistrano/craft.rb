require "capistrano/dsl/craft"
self.extend Capistrano::DSL::Craft

SSHKit::Backend::Netssh.send(:include, Capistrano::DSL::Craft)
SSHKit::Backend::Local.send(:include, Capistrano::DSL::Craft)

require "capistrano/composer"
require "capistrano/craft/craft"
require "capistrano/craft/version"

namespace :load do
  task :defaults do
    load "capistrano/craft/defaults.rb"
  end
end
