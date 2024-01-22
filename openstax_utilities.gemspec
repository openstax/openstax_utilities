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

  s.files = Dir["{app,config,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.0", '< 8.0'
  s.add_dependency "lev"
  s.add_dependency "keyword_search"
  s.add_dependency "request_store"
  s.add_dependency "faraday"
  s.add_dependency "faraday-http-cache"
  s.add_dependency "aws-sdk-autoscaling"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency "faker"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
end
