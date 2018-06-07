module EgovUtils
  module Helpers
    module Tags

      module DatetimeLocalFieldPatch
        private
          def format_date(value)
            value.try(:strftime, "%Y-%m-%dT%H:%M")
          end
      end
    end
  end
end
