module BootstrapForm
  module CustomFileField

    # Give :choose_label as a option for changing the langfile default.
    def custom_file_field(name, *args)
      options = args.extract_options!.symbolize_keys!
      args << options

      form_group_builder(name, options) do
        content_tag('div', class: 'custom-file') do
          control = file_field_without_bootstrap(name, options.merge(class: 'custom-file-input'))
          label = label(name, @template.t('bootstrap.file_input.placeholder', default: [options[:choose_label], 'Choose file'].compact), class: "custom-file-label")
          concat(control).concat(label)
        end
      end
    end

  end
end
