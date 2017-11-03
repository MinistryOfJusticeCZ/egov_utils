module EgovUtils
  module ApplicationHelper

    def i18n_js_set_locales_tag
      s = ''
      s << "window.I18n.defaultLocale = '#{I18n.default_locale}';"
      s << "window.I18n.locale = '#{I18n.locale}';"
      s
      javascript_tag s
    end

  end
end
