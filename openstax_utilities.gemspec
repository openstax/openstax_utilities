$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "openstax_utilities/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "openstax_utilities"
  s.version     = OpenstaxUtilities::VERSION
  s.authors     = ["JP Slavinsky"]
  s.email       = ["jps@kindlinglabs.com"]
  s.homepage    = "http://github.com/openstax/openstax_utilities"
  s.summary     = "Utilities for OpenStax web sites"
  s.description = "Utilities for OpenStax web sites"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]
end
