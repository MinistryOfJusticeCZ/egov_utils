module EgovUtils
  module HasAuditTrail

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def has_audit_trail(options = {})
        return if self.included_modules.include?(EgovUtils::HasAuditTrail::AuditTrailMethods)

        default_options = {
          :non_audited_columns => %w(id updated_at created_at lft rgt lock_version),
          :important_columns => [],
          :format_detail_date_columns => [],
          :format_detail_time_columns => [],
          :format_detail_reflection_columns => [],
          :format_detail_boolean_columns => [],
          :format_detail_hours_columns => []
        }

        cattr_accessor :audit_trail_options
        self.audit_trail_options = default_options.dup

        options.each do |k,v|
          self.audit_trail_options[k] = Array(self.audit_trail_options[k]) | v
        end

        send :include, EgovUtils::HasAuditTrail::AuditTrailMethods
      end

    end

    module AuditTrailMethods

      def self.included(base)
        base.class_eval do

          has_many :audit_records, :as => :audited, :dependent => :destroy, :inverse_of => :audited

        end
      end

      def clear_current_journal
        @current_record = nil
      end

      def init_audit_record(user, notes = '')
        @current_record ||= AuditRecord.new(:audited => self, :user => user, :notes => notes)
      end

      # Returns the names of attributes that are journalized when updating the issue
      def journalized_attribute_names
        self.class.column_names - self.audit_trail_options[:non_audited_columns]
      end

      private

      def create_audit_record
        if @current_record
          @current_record.save
        end
      end

    end
  end
end
EasyExtensions::PatchManager.register_rails_patch 'ActiveRecord::Base', 'EasyPatch::ActsAsEasyJournalized'
