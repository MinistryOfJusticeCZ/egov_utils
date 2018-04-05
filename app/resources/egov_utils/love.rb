require 'activeresource'


module EgovUtils
  module AzaharaJsonResourceFormat
    include ActiveResource::Formats::JsonFormat
    extend self

    def decode(json)
      resources = super(json)
      (resources.is_a?(Hash) && resources.key?('entities')) ? resources['entities'] : resources
    end

  end
end



module EgovUtils
  class Love < ::ActiveResource::Base

    def self.config
      file = Rails.root.join('config', 'config.yml')
      File.exists?(file) ? YAML.load_file(file) : {}
    end

    self.site = "#{config['love_url'] || Rails.configuration.try(:love_url)}/api/v1/"
    self.format = EgovUtils::AzaharaJsonResourceFormat


    def self.where(clauses = {})
      raise ArgumentError, "expected a clauses Hash, got #{clauses.inspect}" unless clauses.is_a? Hash
      find(:all, params: {f: clauses})
    end
  end
end
