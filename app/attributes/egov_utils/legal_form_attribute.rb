module EgovUtils
  class LegalFormAttribute < AzaharaSchema::Attribute

    def initialize(model, name)
      super(model, name, 'love')
    end

    def available_values
      @available_values ||= EgovUtils::LegalForm.all.collect{|lf| [lf.name, lf.key] }
    end

  end
end
