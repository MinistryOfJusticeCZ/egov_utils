class IcoValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless !value.nil? && value =~ /\A\d{7,9}\z/
      record.errors.add(attribute, (options[:message] || :ico_format))
    end
  end
end
