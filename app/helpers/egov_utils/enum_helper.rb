module EgovUtils
  module EnumHelper

    def enum_values_for_select(klass, method)
      plur_method = method.to_s.pluralize
      klass.send(plur_method).collect{|val, _| [t("activerecord.attributes.#{klass.model_name.i18n_key}.#{plur_method}.#{val}"), val]}
    end

  end
end
