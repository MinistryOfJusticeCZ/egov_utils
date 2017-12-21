module BootstrapForm
  module CustomFileField

    def custom_file_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      args << options
      form_group_builder(name, options.reverse_merge(control_class: nil)) do
        html = file_field_without_bootstrap(name, options.merge(class: 'custom-file-input')) + " " + content_tag('span', '', class: ['custom-file-control', options[:class]].compact.join(' '))
        label(name, html, class: "custom-file form-control")
      end
    end

  end
end
