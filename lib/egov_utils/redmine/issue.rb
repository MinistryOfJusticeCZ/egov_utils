require 'active_resource'

module EgovUtils
  module Redmine

    def self.config
      EgovUtils::Settings.redmine
    end

    def self.configured?
      config['url'] && config['project_id']
    end

    class Issue < ActiveResource::Base
      self.site = EgovUtils::Redmine.config['url']
      self.ssl_options = {verify_mode: OpenSSL::SSL::VERIFY_NONE}

      headers["X-Redmine-API-Key"] = EgovUtils::Redmine.config['api_key'] if EgovUtils::Redmine.config['api_key']

      def self.collection_path(prefix_options = {},query_options=nil)
        super
        query_options[:query_id] ||= EgovUtils::Redmine.config['query_id'] if EgovUtils::Redmine.config['query_id']
        prefix_options[:project_id] ||= EgovUtils::Redmine.config['project_id']
        "/projects/#{prefix_options[:project_id]}/#{collection_name}.#{format.extension}#{query_string(query_options)}"
      end

      def self.instantiate_collection(collection, original_params = {}, prefix_options = {})
        collection = collection[collection_name] if collection[collection_name].is_a?(Array)
        super(collection, original_params, prefix_options)
      end
    end

  end
end
