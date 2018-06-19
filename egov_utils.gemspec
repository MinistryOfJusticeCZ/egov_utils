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

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1"

  # Use ActiveModel has_secure_password
  s.add_runtime_dependency 'bcrypt', '~> 3.1'

  s.add_dependency 'activeresource', '~> 5.0'

  s.add_dependency 'haml', '~> 5.0'
  s.add_dependency 'rails-i18n', '~> 5.0'
  s.add_dependency "i18n-js", '~> 3.0'

  s.add_dependency 'net-ldap', '~> 0.16'

  s.add_dependency 'settingslogic', '~> 2.0'
  s.add_dependency "audited", "~> 4.4"
  s.add_dependency 'paranoia', '~> 2.4'
  s.add_dependency 'cancancan', '~> 2.0'
  s.add_dependency 'money', '~> 6.11'


  s.add_runtime_dependency 'request_store_rails', '~> 1.0'


  s.add_runtime_dependency 'jquery-rails', '~> 4.3'
  s.add_runtime_dependency 'jquery-ui-rails', '~> 6.0'
  s.add_runtime_dependency 'bootstrap', '~> 4.0'
  s.add_runtime_dependency 'sass-rails', '~> 5.0'
  s.add_runtime_dependency 'font-awesome-sass', '~> 4.7'
  s.add_runtime_dependency 'bootstrap_form', '~> 4.0.0.alpha'
  s.add_runtime_dependency 'bootstrap4-datetime-picker-rails', '~> 0.1'
  s.add_runtime_dependency 'momentjs-rails', '~> 2.20'
  s.add_runtime_dependency 'modernizr-rails', '~> 2.7'
  s.add_runtime_dependency 'clipboard-rails', '~> 1.7'
  s.add_runtime_dependency 'vuejs-rails', '~> 2.5'

  s.add_runtime_dependency 'azahara_schema', '~> 0.3'
  s.add_runtime_dependency 'egon_gate', '~> 0.1'

  s.add_runtime_dependency 'cookies_eu', '~> 1.6'


  s.add_development_dependency "sqlite3"
  # s.add_development_dependency 'ruby-ldapserver', '~> 0.5.0'
  # s.add_development_dependency "fakeldap"
  # s.add_development_dependency "ladle"
end
