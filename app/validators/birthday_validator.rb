class BirthdayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_nil] && value.presence.nil?
    record.errors.add(attribute, :in_past) if !value || value >= Time.now.to_date
    record.errors.add(attribute, :after_1920) if !value || value <= Date.new(1920, 1, 1)
  end
end
