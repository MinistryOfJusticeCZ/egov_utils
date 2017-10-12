module EgovUtils
  class AllRoleNames < AzaharaSchema::Attribute

    def filter?
      false
    end

    def build_json_options!(options)
      options[:methods] ||= []
      options[:methods] << 'all_role_names'
      options
    end

  end
end
