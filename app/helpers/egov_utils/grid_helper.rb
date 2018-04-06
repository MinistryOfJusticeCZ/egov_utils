module EgovUtils
  module GridHelper

    def type_for_grid(type)
      case type
      when 'integer', 'float', 'decimal'
        'Number'
      when 'string', 'text', 'list', 'love'
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

    def entity_template_path_for_schema(schema, id_template='{id}')
      if schema.respond_to?('engine_name')
        self.public_send(schema.engine_name).polymorphic_path(schema.model) + "/#{id_template}"
      else
        polymorphic_path(schema.model) + "/#{id_template}"
      end
    rescue NoMethodError => e
      nil
    end

    # TODO - what if the attribute is main for associated schema (legal_person-name for person schema)
    def entity_template_path(schema, attribute)
      if attribute.name == schema.main_attribute_name
        entity_template_path_for_schema(schema)
      elsif (base_schema = attribute.try(:base_schema)) && attribute.name =~ /#{base_schema.main_attribute_name}/
        entity_template_path_for_schema(base_schema, "{#{attribute.primary_key_name}}")
      end
    end

    def column_for_grid(grid, attribute)
      s = "{"
      s << "field: '#{attribute.name}'"
      s << ", title: '#{attribute.attribute_name.human}'"

      if (template_path = entity_template_path(grid.schema, attribute))
        s << ", columnTemplate: '<a href=\"#{template_path}\">{#{attribute.name}}</div>'"
      end

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
