$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "openstax/utilities/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "openstax_utilities"
  s.version     = Openstax::Utilities::VERSION
  s.authors     = ["JP Slavinsky"]
  s.email       = ["jps@kindlinglabs.com"]
  s.homepage    = "http://github.com/openstax/openstax_utilities"
  s.summary     = "Utilities for OpenStax web sites"
  s.description = "Utilities for OpenStax web sites"

  s.files = Dir["{app,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]
end
