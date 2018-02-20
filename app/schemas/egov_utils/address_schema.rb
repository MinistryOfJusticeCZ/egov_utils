module EgovUtils
  class AddressSchema < AzaharaSchema::ModelSchema

    def attribute_for_column(col)
      case col.name
      when 'district'
        EgovUtils::District.new
      when 'region'
        EgovUtils::Region.new
      else
        super
      end
    end

    def main_attribute_name
      'full_address'
    end

    def path
      'to_s'
    end

    def initialize_available_attributes
      @available_attributes ||= []
      @available_attributes << EgovUtils::FullAddress.new(model, 'full_address', schema: self)
      super
    end

  end
end
