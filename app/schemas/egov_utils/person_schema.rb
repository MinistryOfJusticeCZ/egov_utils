module EgovUtils
  class PersonSchema < AzaharaSchema::ModelSchema

    def main_attribute_name
      'fullname'
    end

    def initialize_available_attributes
      @available_attributes ||= []
      @available_attributes << AzaharaSchema::DerivedAttribute.new(model, 'fullname', :concat, 'firstname', 'lastname', schema: self)
      super
    end

  end
end
