require 'settingslogic'

module EgovUtils

  def self.config_file
    ENV.fetch('EGOVUTILS_CONFIG') { Rails.root.join('config', 'config.yml') }
  end

  class Settings < ::Settingslogic
    source (File.exists?(EgovUtils.config_file) ? EgovUtils.config_file : {})

    # namespace Rails.env

    def allow_internal_accounts?
      true
    end

    def allow_register?
      allow_internal_accounts? && allow_register
    end

    def allow_password_reset?
      allow_internal_accounts? && allow_password_reset
    end

  end

  Settings['allow_register'] ||= false
  Settings['allow_password_reset'] ||= true

  Settings['redmine'] ||= Settingslogic.new({})
  Settings['redmine']['enabled'] ||= false

end
