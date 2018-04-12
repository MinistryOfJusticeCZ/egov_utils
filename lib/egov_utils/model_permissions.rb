module EgovUtils
  class ModelPermissions

    def self.build(model, ability)
      klass = model
      klasses = [klass]
      while klass != klass.base_class
        klass = klass.superclass
        klasses << klass
      end
      klasses.each do |kls|
        perm_class = "#{kls.name}Permissions".safe_constantize
        return perm_class.new(ability) if perm_class
      end
      EgovUtils::ModelPermissions.new(model, ability)
    end

    attr_reader :model, :ability

    def initialize(model, ability)
      @model, @ability = model, ability
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

    def assignable_associations
      model.reflect_on_all_associations.select{|assoc| model.method_defined?("#{assoc.name}_attributes=".to_sym) }
    end

    def editable_attributes(action=:update)
      return [] unless ability.can?(action, model)
      attributes = basic_editable_attributes(action)
      assignable_associations.each{|assoc| add_editable_association_attributes(attributes, assoc, action) }
      attributes
    end

    #TODO nested attributes should take entity as well - what to do with has_many?
    def editable_attributes_for(entity, action=:update)
      return [] unless ability.can?(action, entity)
      attributes = basic_editable_attributes(action)
      assignable_associations.each{|assoc| add_editable_association_attributes_for(attributes, assoc, entity, action) }
      attributes
    end

    def add_editable_association_attributes(attributes, assoc, action)
      assoc_permissions = self.class.build(assoc.klass, ability)

      assoc_attributes  = assoc_permissions.editable_attributes(action)
      assoc_attributes.unshift('id') if ability.can?(:update, assoc.klass)
      assoc_attributes_hash = { "#{assoc.name}_attributes" => assoc_attributes }

      case assoc.macro
      when :has_many
        attributes << assoc_attributes_hash
      when :has_one, :belongs_to
        if ability.can?(:update, assoc.klass)
          attributes << assoc.foreign_key if assoc.macro == :belongs_to
          attributes << assoc_attributes_hash
        else
          attributes << assoc_attributes_hash
        end
      else
        attributes << assoc_attributes_hash
      end
    end

    def add_editable_association_attributes_for(attributes, assoc, entity, action)
      case assoc.macro
      when :has_many

      else
        add_editable_association_attributes(attributes, assoc, action)
      end
    end

  end
end
