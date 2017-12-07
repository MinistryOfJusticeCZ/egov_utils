class FileuidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_nil] && value.presence.nil?
    if value.is_a?(EgovUtils::Fileuid)
      record.errors.add(attribute, (options[:message] || :fileuid_format)) if value.invalid?
    elsif !match_regexp?(record, attribute, value)
      record.errors.add(attribute, (options[:message] || :fileuid_format))
    end
  end

  def match_regexp?(record, attribute, value)
    type = nil
    if type
      value =~ EgovUtils::Fileuid::TYPES[type].to_regex
    else
      EgovUtils::Fileuid::TYPES.values.any?{|type_def| value =~ type_def.to_regex }
    end
  end
end
