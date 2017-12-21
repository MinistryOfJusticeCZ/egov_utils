module BootstrapForm
  module CheckBoxPatch

    # TODO: post to upstream
    def check_box(name, options = {}, checked_value = "1", unchecked_value = "0", &block)
      options = options.symbolize_keys!
      check_box_options = options.except(:label, :label_class, :wrapper_class, :help, :inline)

      label_classes = [options[:label_class], 'form-check-label']
      unless options.delete(:skip_required)
        label_classes << "required" if required_attribute?(object, name)
      end
      options[:label_class] = label_classes.compact.join(' ')


      check_box_options[:class] = ['form-check-input', check_box_options[:class]].compact.join(' ')


      html = check_box_without_bootstrap(name, check_box_options, checked_value, unchecked_value)
      label_content = block_given? ? capture(&block) : options[:label]
      html.concat(' ').concat(label_content || (object && object.class.human_attribute_name(name)) || name.to_s.humanize)

      label_name = name
      # label's `for` attribute needs to match checkbox tag's id,
      # IE sanitized value, IE
      # https://github.com/rails/rails/blob/c57e7239a8b82957bcb07534cb7c1a3dcef71864/actionview/lib/action_view/helpers/tags/base.rb#L116-L118
      if options[:multiple]
        label_name =
          "#{name}_#{checked_value.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase}"
      end

      disabled_class = " disabled" if options[:disabled]
      label_class    = options[:label_class]

      if options[:inline]
        label_class = " #{label_class}" if label_class
        label(label_name, html, class: "checkbox-inline#{disabled_class}#{label_class}")
      else
        wrapper_class = ['form-checkbox', options[:wrapper_class]]
        wrapper_class << error_class if has_error?(name)
        wrapper_class = wrapper_class.compact.join(' ')
        content_tag(:div, class: "#{wrapper_class}#{disabled_class}") do
          label(label_name, html, class: label_class).concat(generate_help(name, options[:help]))
        end
      end
    end

  end
end
