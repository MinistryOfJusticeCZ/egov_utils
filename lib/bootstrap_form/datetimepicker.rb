module BootstrapForm
  module Datetimepicker
    def date_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      options[:data] = {provide: 'datepicker', 'date-format' => 'L'}.merge(options[:data] || {})
      args << options
      super
    end

    def datetime_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      options[:data] = {provide: 'datepicker'}.merge(options[:data] || {})
      args << options
      super
    end
  end
end
