require 'activeresource'

module EgovUtils
  class Love < ::ActiveResource::Base

    def self.config
      file = Rails.root.join('config', 'config.yml')
      File.exists?(file) ? YAML.load_file(file) : {}
    end

    self.site = "#{config['love_url'] || Rails.configuration.try(:love_url)}/api/v1/"

    def self.where(clauses = {})
      raise ArgumentError, "expected a clauses Hash, got #{clauses.inspect}" unless clauses.is_a? Hash
      find(:all, params: {f: clauses})
    end
  end
end
