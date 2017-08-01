module EgovUtils
  class Region < ActiveSchema::Attribute

    def initialize
      super(EgovUtils::Address, 'region', 'list')
    end

    def available_values
      EgovUtils::Address.regions.collect{|d| [d,d] }
    end

  end
end
