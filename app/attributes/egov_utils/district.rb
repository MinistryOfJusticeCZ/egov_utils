module EgovUtils
  class District < ActiveSchema::Attribute

    def initialize
      super(EgovUtils::Address, 'district', 'list')
    end

    def available_values
      EgovUtils::Address.districts.collect{|d| [d,d] }
    end

  end
end
