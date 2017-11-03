module EgovUtils
  class Region < AzaharaSchema::Attribute

    def initialize
      super(EgovUtils::Address, 'region', 'love')
    end

    def available_values
      EgovUtils::Address.regions.collect{|d| [d[:name],d[:name]] }
    end

  end
end
