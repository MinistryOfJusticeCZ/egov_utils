module EgovUtils
  module GridHelper
    def type_for_grid(type)
      case type
      when 'integer'
        'Number'
      when 'string', 'list'
        'String'
      when 'datetime'
        'Date'
      else
        raise "Undefined grid type for type #{type}"
      end
    end

    def field_for_grid(attribute)
      s = "\'"
      s << attribute.name
      s << '\': {path: "'
      s << attribute.path
      s << '", type: '
      s << type_for_grid(attribute.type)
      s << '}'
      s
    end

    def column_for_grid(grid, attribute)
      s = "{"
      s << "field: '#{attribute.name}'"
      s << ", title: '#{I18n.t('model_attributes.'+grid.model_i18n_key.to_s+'.'+attribute.name)}'"
      s << ", columnTemplate: '<a href=\"#{polymorphic_path(grid.schema.model)}/{id}\">{#{attribute.name}}</div>'" if attribute.name == grid.schema.main_attribute_name
      if attribute.type == 'list'
        s << ", format: ( (value) -> I18n.t(value, {scope: 'activerecord.attributes.#{attribute.model.model_name.i18n_key}.#{attribute.name.to_s.pluralize}'}) ) "
      end
      s << "}"
    end
  end
end
