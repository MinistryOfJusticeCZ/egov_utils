module EgovUtils
  module ApplicationHelper

    def i18n_js_set_locales_tag
      s = ''
      s << "window.I18n.defaultLocale = '#{I18n.default_locale}';"
      s << "window.I18n.locale = '#{I18n.locale}';"
      s
      javascript_tag s
    end

    def main_schema_attribute(schema)
      schema.available_attributes_hash[schema.main_attribute_name]
    end

    def role_based_render(name, *attributes)
      res = ''.html_safe
      current_user.all_role_names.each do |role_name|
        res << render(name+'_'+role_name, *attributes) if lookup_context.exists?(name+'_'+role_name, [], true)
      end
      res
    end

  end
end
