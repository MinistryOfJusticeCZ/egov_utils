module BootstrapForm
  module CheckBoxPatch

    # TODO: check upstream - it is on master on 29-1-2018 - only required is not there
    def check_box(name, options = {}, checked_value = "1", unchecked_value = "0", &block)
      options = options.symbolize_keys!
      check_box_options = options.except(:label, :label_class, :wrapper_class, :help, :inline)

      label_classes = [options[:label_class], 'form-check-label']
      unless options.delete(:skip_required)
        label_classes << "required" if required_attribute?(object, name)
      end
      options[:label_class] = label_classes.compact.join(' ')

      super
    end

  end
end
