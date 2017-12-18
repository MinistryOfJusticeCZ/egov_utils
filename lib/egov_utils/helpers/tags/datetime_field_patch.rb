module EgovUtils
  module Helpers
    module Tags
      module DatetimeFieldPatch

        def render
          pickerize_options! if @options.stringify_keys['datetimepicker']
          super
        end

        protected

          def pickerize_options!
            options = @options.stringify_keys
            picker_data = {'provide' => 'datepicker', 'date-min-date' => format_date(datetime_value(options["min"])), 'date-max-date' => format_date(datetime_value(options["min"])) }
            @options[:data] = picker_data.merge(options['data'] || {})
          end

      end
    end
  end
end
