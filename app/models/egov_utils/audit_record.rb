module EgovUtils
  class AuditRecord < ApplicationRecord
    belongs_to :audited, :polymorphic => true
    belongs_to :user

    has_many :details, :class_name => "AuditDetail", :dependent => :delete_all, :inverse_of => :audit_record
    attr_accessor :indice
    attr_protected :id

    after_create :send_notification

    def save(*args)
      journalize_changes
      # Do not save an empty journal
      (details.empty? && notes.blank?) ? false : super
    end

    # Stores the values of the attributes and custom fields of the journalized object
    def start
      if journalized
        @attributes_before_change = journalized.journalized_attribute_names.inject({}) do |h, attribute|
          h[attribute] = journalized.send(attribute)
          h
        end
      end
      self
    end

    # Adds a journal detail for an attachment that was added or removed
    def journalize_attachment(attachment, added_or_removed)
      key = (added_or_removed == :removed ? :old_value : :value)
      details << JournalDetail.new(
          :property => 'attachment',
          :prop_key => attachment.id,
          key => attachment.filename
        )
    end

    private

    # Generates journal details for attribute and custom field changes
    def journalize_changes
      # attributes changes
      if @attributes_before_change
        journalized.journalized_attribute_names.each {|attribute|
          before = @attributes_before_change[attribute]
          after = journalized.send(attribute)
          next if before == after || (before.blank? && after.blank?)
          add_attribute_detail(attribute, before, after)
        }
      end
      if @custom_values_before_change
        # custom fields changes
        journalized.custom_field_values.each {|c|
          before = @custom_values_before_change[c.custom_field_id]
          after = c.value
          next if before == after || (before.blank? && after.blank?)

          if before.is_a?(Array) || after.is_a?(Array)
            before = [before] unless before.is_a?(Array)
            after = [after] unless after.is_a?(Array)

            # values removed
            (before - after).reject(&:blank?).each do |value|
              add_custom_value_detail(c, value, nil)
            end
            # values added
            (after - before).reject(&:blank?).each do |value|
              add_custom_value_detail(c, nil, value)
            end
          else
            add_custom_value_detail(c, before, after)
          end
        }
      end
      start
    end

    # Adds a journal detail for an attribute change
    def add_attribute_detail(attribute, old_value, value)
      add_detail('attr', attribute, old_value, value)
    end

    # Adds a journal detail
    def add_detail(property, prop_key, old_value, value)
      details << JournalDetail.new(
          :property => property,
          :prop_key => prop_key,
          :old_value => old_value,
          :value => value
        )
    end

    def send_notification
      # TODO
    end
  end
end
