module EgovUtils
  class LegalPersonSchema < AzaharaSchema::ModelSchema

    def self.attribute(model, attr_name, attr_type=nil)
      case attr_name
      when 'legal_form'
        LegalFormAttribute.new(model, attr_name)
      else
        super
      end
    end

  end
end
