module EgovUtils
  class EngineSchema < AzaharaSchema::ModelSchema

    def self.engine_name
      self.name.split('::').first.underscore
    end

    def engine_name
      self.class.engine_name
    end

  end
end
