module EgovUtils
  module Helpers
    module FormHelper

      # Returns an input tag of the "fileuid" type tailored for accessing a specified attribute (identified by +method+) on an object
      # assigned to the template (identified by +object+). Additional options on the input tag can be passed as a
      # hash with +options+.
      def fileuid_field(object_name, method, options = {})
        Tags::FileuidField.new(object_name, method, self, options).render
      end

      def select2(object_name, method, choices = nil, options = {}, html_options = {}, &block)
        select2_data_hash = {provide: 'select2'}
        if options.delete(:include_blank) || options[:prompt]
          select2_data_hash['allow-clear'] = true
          select2_data_hash['placeholder'] = options.delete(:prompt) || ''
        end
        if choices.is_a?(Hash)
          select2_data_hash[:ajax] = choices
          choices = []
          if options[:object] && options[:object].public_send(method)
            value_text = options.delete(:value_text) || ->(object){ options[:object].public_send(method.to_s.gsub(/_id$/, '')).to_s }
            choices << [value_text.respond_to?(:call) ? value_text.call(options[:object]) : value_text, options[:object].public_send(method)]
          end
        end
        select(object_name, method, choices, options, html_options.deep_merge(data: select2_data_hash))
      end

    end
  end
end
