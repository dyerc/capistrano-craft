lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "capistrano/craft/version"

Gem::Specification.new do |spec|
  spec.name          = "capistrano-craft"
  spec.version       = Capistrano::Craft::VERSION
  spec.authors       = ["Chris Dyer"]
  spec.email         = ["chris@cdyer.co.uk"]

  spec.summary       = %q{Capistrano Craft - Easy deployment of Symfony 4 apps with Ruby over SSH}
  spec.description   = %q{Craft CMS specific Capistrano tasks}
  spec.homepage      = "https://github.com/dyerc/capistrano-craft"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dyerc/capistrano-craft"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  
  spec.require_paths = ["lib"]

  spec.add_dependency 'capistrano', '~> 3.1'
  spec.add_dependency 'capistrano-composer', '~> 0.0.6'
end
