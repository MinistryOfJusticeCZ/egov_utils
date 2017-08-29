module EgovUtils
  module UserUtils
    class Role

      class_attribute :role_name
      self.role_name = nil

      def self.roles
        @@roles ||= {}
      end

      def self.find(name)
        roles[name]
      end

      def self.add(name)
        roles[name] = self
        self.role_name = name
      end

      def define_abilities(ability)
      end

    end
  end
end
