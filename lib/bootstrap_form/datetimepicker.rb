module BootstrapForm
  module Datetimepicker
    def date_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      options[:datetimepicker] = true
      options[:data] = {'date-format' => 'L', 'date-extra-formats' => [BootstrapForm::DATE_FORMAT_JS]}.merge(options[:data] || {})
      options[:append] = calendar_addon
      args << options
      super
    end

    def datetime_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      options[:datetimepicker] = true
      options[:append] = calendar_addon
      args << options
      super
    end

    def datetime_local_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      options[:datetimepicker] = true
      options[:append] = calendar_addon
      args << options
      super
    end

    private

      def calendar_addon
        content_tag('i', '', class: 'fa fa-calendar')
      end
  end
end
