module EgovUtils
  class UserSchema < EgovUtils::EngineSchema

    def main_attribute_name
      'fullname'
    end

    def initialize_available_attributes
      @available_attributes ||= []
      @available_attributes << AzaharaSchema::DerivedAttribute.new(model, 'fullname', :concat, 'firstname', 'lastname', schema: self)
      super
      @available_attributes << AllRoleNames.new(model, 'all_role_names', 'string')
    end

  end
end
