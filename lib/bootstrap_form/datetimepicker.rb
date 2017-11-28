module BootstrapForm
  module Datetimepicker
    def date_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      options[:data] = {provide: 'datepicker', 'date-format' => 'L'}.merge(options[:data] || {})
      options[:append] = calendar_addon
      args << options
      super
    end

    def datetime_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      options[:data] = {provide: 'datepicker'}.merge(options[:data] || {})
      options[:append] = calendar_addon
      args << options
      super
    end

    def datetime_local_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      options[:data] = {provide: 'datepicker'}.merge(options[:data] || {})
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
