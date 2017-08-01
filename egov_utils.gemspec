$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "egov_utils/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "egov_utils"
  s.version     = EgovUtils::VERSION
  s.authors     = ["Ondřej Ezr"]
  s.email       = ["oezr@msp.justice.cz"]
  s.homepage    = "https://git.servis.justice.cz"
  s.summary     = "The eGoverment utilities is set of functionalities to support basic eGoverment IS needs."
  s.description = "We hope it will help create better systems for all the eGoverment. In Czech Republic and maybe further."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1"

  # Use ActiveModel has_secure_password
  s.add_dependency 'bcrypt', '~> 3.1.11'

  s.add_dependency "audited", "~> 4.4"

  s.add_development_dependency "sqlite3"
end
