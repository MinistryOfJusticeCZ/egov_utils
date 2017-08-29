module EgovUtils
  class Principal < ApplicationRecord
    self.abstract_class = true

    serialize :roles, Array

    def has_role?(role)
      roles.include?(role)
    end
  end
end
