module EgovUtils
  class AuditDetail < ApplicationRecord
    belongs_to :audit_record

    def value=(arg)
      write_attribute :value, normalize(arg)
    end

    def old_value=(arg)
      write_attribute :old_value, normalize(arg)
    end

    private

      def normalize(v)
        case v
        when true
          "1"
        when false
          "0"
        when Date
          v.strftime("%Y-%m-%d")
        else
          v
        end
      end
  end
end
