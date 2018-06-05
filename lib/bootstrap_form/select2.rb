module BootstrapForm
  module Select2

    def select2(method, choices = nil, options = {}, html_options = {}, &block)
      form_group_builder(method, options, html_options) do
        prepend_and_append_input(method, options) do
          @template.select2(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options), &block)
        end
      end
    end

  end
end
