module EgovUtils
  module GridHelper

    def type_for_grid(type)
      case type
      when 'integer', 'float', 'decimal'
        'Number'
      when 'string', 'list', 'love'
        'String'
      when 'date', 'datetime'
        'Date'
      when 'boolean'
        'Boolean'
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
      s << ", title: '#{attribute.attribute_name.human}'"
      s << ", columnTemplate: '<a href=\"#{polymorphic_path(grid.schema.model)}/{id}\">{#{attribute.name}}</div>'" if attribute.name == grid.schema.main_attribute_name
      if attribute.type == 'list'
        s << ", format: ( (value) -> I18n.t('#{attribute.attribute_name.i18n_scoped_list_prefix}'+'.'+value, {defaults: $.map( #{attribute.attribute_name.i18n_list_fallback_prefixes.to_json}, (pref, i)-> {scope: (pref + '.' + value)} )}) ) "
      elsif attribute.type == 'date'
        s << ", format: ( (value)-> I18n.l('date.formats.default', value) )"
      elsif attribute.type == 'datetime'
        s << ", format: ( (value)-> I18n.l('time.formats.default', value) )"
      end
      s << "}"
    end

    def additional_grid_edit_buttons(schema)
    end
  end
end
