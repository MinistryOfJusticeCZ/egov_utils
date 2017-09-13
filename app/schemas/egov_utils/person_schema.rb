module EgovUtils
  class PersonSchema < AzaharaSchema::ModelSchema

    def main_attribute_name
      'fullname'
    end

    def initialize_available_attributes
      @available_attributes ||= []
      @available_attributes << Fullname.new(model, 'fullname', 'string')
      super
    end

  end
end
