class FileuidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_nil] && value.presence.nil?
    unless value =~ /\A\d+-\w{1,4}-\d+\/\d{4}\z/i
      record.errors.add(attribute, (options[:message] || :fileuid_format))
    end
  end
end
