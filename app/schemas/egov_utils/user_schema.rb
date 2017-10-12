module EgovUtils
  class UserSchema < AzaharaSchema::ModelSchema

    def main_attribute_name
      'fullname'
    end

    def initialize_available_attributes
      @available_attributes ||= []
      @available_attributes << Fullname.new(model, 'fullname', 'string')
      super
      @available_attributes << AllRoleNames.new(model, 'all_role_names', 'string')
    end

  end
end
