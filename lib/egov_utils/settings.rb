require 'settingslogic'

module EgovUtils

  def self.config_file
    ENV.fetch('EGOVUTILS_CONFIG') { Rails.root.join('config', 'config.yml') }
  end

  class Settings < ::Settingslogic
    source (File.exists?(EgovUtils.config_file) ? EgovUtils.config_file : {})

    # namespace Rails.env

    def allow_register?
      allow_register
    end

  end

  Settings['allow_register'] ||= false

end
