module EgovUtils
  class LegalPerson < AbstractPerson

    belongs_to :person, class_name: 'EgovUtils::Person'

    def fullname
      name
    end

    def to_s
      "#{fullname} (#{ico})"
    end

  end
end
