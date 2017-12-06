require 'settingslogic'

module EgovUtils
  class Settings < ::Settingslogic
    source ENV.fetch('EGOVUTILS_CONFIG') { Rails.root.join('config', 'config.yml') }

    # namespace Rails.env

    def allow_register?
      allow_register
    end

  end

  Settings['allow_register'] ||= false

end
