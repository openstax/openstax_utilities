$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "openstax/utilities/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "openstax_utilities"
  s.version     = OpenStax::Utilities::VERSION
  s.authors     = ["JP Slavinsky"]
  s.email       = ["jps@kindlinglabs.com"]
  s.homepage    = "http://github.com/openstax/openstax_utilities"
  s.summary     = "Utilities for OpenStax web sites"
  s.description = "Shared utilities for OpenStax web sites"
  s.license     = "MIT"

  s.files = Dir["{app,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 3.1"
  s.add_dependency "keyword_search"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "faker"
  s.add_development_dependency "squeel"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"
end
