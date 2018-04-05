module EgovUtils
  class ModelPermissions

    def self.build(model, user)
      klass = model
      klasses = [klass]
      while klass != klass.base_class
        klass = klass.superclass
        klasses << klass
      end
      klasses.each do |kls|
        perm_class = "#{kls.name}Permissions".safe_constantize
        return perm_class.new(user) if perm_class
      end
      EgovUtils::ModelPermissions.new(model, user)
    end

    attr_reader :model, :user

    def initialize(model, user)
      @model, @user = model, user
    end

    def readable_attributes(action=:show)
      model.column_names
    end

    def basic_editable_attributes(action=:update)
      model.column_names - ['id', 'updated_at', 'created_at']
    end

    def basic_editable_attributes_for(entity, action=:update)
      basic_editable_attributes(action)
    end

    def editable_attributes(action=:update)
      attributes = basic_editable_attributes(action)
      assocs = model.reflect_on_all_associations.select{|assoc| model.method_defined?("#{assoc.name}_attributes=".to_sym) }
      attributes << assocs.each_with_object({}) {|assoc, obj| obj["#{assoc.name}_attributes"] = self.class.build(assoc.klass, user).editable_attributes(action) }
      attributes
    end

    #TODO nested attributes should take entity as well - what to do with has_many?
    def editable_attributes_for(entity, action=:update)
      attributes = basic_editable_attributes(action)
      assocs = model.reflect_on_all_associations.select{|assoc| model.method_defined?("#{assoc.name}_attributes=".to_sym) }
      attributes << assocs.each_with_object({}) {|assoc, obj| obj["#{assoc.name}_attributes"] = self.class.build(assoc.klass, user).editable_attributes_for(action) }
      attributes
    end

  end
end
