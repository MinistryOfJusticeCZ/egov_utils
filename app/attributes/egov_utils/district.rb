module EgovUtils
  class District < AzaharaSchema::Attribute

    def initialize
      super(EgovUtils::Address, 'district', 'list')
    end

    def available_values
      EgovUtils::Address.districts.collect{|d| [d[:name],d[:name]] }
    end

  end
end
