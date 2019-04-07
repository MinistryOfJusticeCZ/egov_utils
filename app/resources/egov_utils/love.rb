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
  class LoveMock < OpenStruct
    def self.all
      raise NotImplemented # you need to provide .all for your mock class
    end

    def self.where(clauses = {})
      all.select do |l|
        clauses.all? do |(k, filter)|
          case filter
          when Array
            filter = filter.collect(&:to_s)
            value = l.send(k)
            pp k, filter, value
            if value.is_a?(Array)
              !(value.collect(&:to_s) & filter).empty?
            else
              filter.include?(value.to_s)
            end
          else
            l.send(k) == filter
          end
        end
      end
    end
  end

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


    # mocking

    def self.inherited(subclass)
      mock_subclass(subclass) if @mocking
    end

    def self.mocked_classes
      @mocked_classes ||= {}
    end

    def self.mock!
      @mocking = true
      EgovUtils::Love.subclasses.each do |cls|
        mock_subclass(cls)
      end
    end

    def self.mock_subclass(subclass)
      mock_cls = "#{subclass.name}Mock".safe_constantize
      return unless mock_cls
      mocked_classes[subclass.name] = subclass
      namespaces = subclass.name.split('::')
      namespace = (namespaces[0..-2].join('::').presence || 'Object').safe_constantize
      namespace.send(:remove_const, namespaces[-1])
      namespace.const_set(namespaces[-1], mock_cls)
    end
  end
end
