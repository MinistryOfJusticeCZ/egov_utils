module EgovUtils
  module ApplicationHelper

    def i18n_js_set_locales_tag
      s = ''
      s << "window.I18n.defaultLocale = '#{I18n.default_locale}';"
      s << "window.I18n.locale = '#{I18n.locale}';"
      s << "window.currency_symbols = #{Money::Currency.table.each_with_object({}){|(k,v),o|o[k]=v[:symbol]}.to_json};"
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

    def google_analytics_code
    end

    def google_analytics_snippet
      javascript_tag(<<-END_JS) if google_analytics_code
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
          (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
          m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
          })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

        ga('create', '#{google_analytics_code}', 'auto');
        ga('send', 'pageview');
      END_JS
    end

  end
end
