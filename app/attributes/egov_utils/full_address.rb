module EgovUtils
  class FullAddress < AzaharaSchema::DerivedAttribute

    def initialize(model, name, **options)
      super(model, name, :concat, 'postcode', 'city', 'street', 'number', options)
    end

    def build_json_options!(options)
      options[:methods] ||= []
      options[:methods] << name
      options
    end

  end
end
