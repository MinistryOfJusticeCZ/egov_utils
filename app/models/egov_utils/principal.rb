module EgovUtils
  class Principal < ApplicationRecord
    self.abstract_class = true

    serialize :roles, Array

    def reload(*attrs)
      @auth_source = nil
      super
    end

    def has_role?(role)
      roles.include?(role)
    end

    def auth_source
      @auth_source ||= EgovUtils::AuthSource.new(provider) if provider.present?
    end
  end
end
