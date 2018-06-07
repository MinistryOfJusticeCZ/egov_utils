module BootstrapForm
  module Datetimepicker
    def date_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      prepare_options(name, options)
      options[:input_group][:data].merge!({'date-format' => 'L', 'date-extra-formats' => [BootstrapForm::DATE_FORMAT_JS]}.merge(options[:data] || {}))
      append_min_max(BootstrapForm::DATE_FORMAT_RUBY, options)
      args << options
      super
    end

#    def datetime_field(name, *args)
#      options = args.extract_options!.symbolize_keys!
#      options[:datetimepicker] = true
#      options[:append] = calendar_addon
#      args << options
#      super
#    end

    def datetime_local_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      prepare_options(name, options)
      options[:input_group][:data].merge!({'date-extra-formats' => [BootstrapForm::DATE_FORMAT_JS+"THH:mm"+(options[:include_seconds] ? ':ss' : '')]}.merge(options[:data] || {}))
      append_min_max(BootstrapForm::DATE_FORMAT_RUBY+"T%T", options)
      args << options
      super
    end

    alias_method :datetime_field, :datetime_local_field

    private

      def prepare_options(name, options)
        input_group_id = default_group_id(name)
        options[:datetimepicker] = true
        options[:append] = calendar_addon
        options[:input_group_class] = 'date'
        options[:input_group] ||= {}
        options[:input_group][:id] = input_group_id
        options[:input_group][:data] = {'target-input' => 'nearest'}
        options[:append_tag] = {data: {toggle: 'datetimepicker', target: '#' + input_group_id}}
        options[:data] ||= {}
        options[:data][:target] = '#' + input_group_id
      end

      def append_min_max(format, options)
        options[:input_group][:data].merge!('date-min-date' => options[:min].try(:strftime, format), 'date-max-date' => options[:max].try(:strftime, format))
      end

      def calendar_addon
        content_tag('i', '', class: 'fa fa-calendar')
      end

      def default_group_id(method_name)
        "#{sanitized_object_name}_#{sanitized_method_name(method_name)}_group"
      end

      def sanitized_object_name
        @object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
      end

      def sanitized_method_name(method_name)
        method_name.to_s.sub(/\?$/, "")
      end
  end
end
