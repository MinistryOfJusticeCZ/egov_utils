module BootstrapForm
  module Select2

    if Gem::Version.new(::Rails::VERSION::STRING) >= Gem::Version.new("4.1.0")
      def select2(method, choices = nil, options = {}, html_options = {}, &block)
        form_group_builder(method, options, html_options) do
          prepend_and_append_input(options) do
            @template.select2(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options), &block)
          end
        end
      end
    else
      def select2(method, choices, options = {}, html_options = {}, &block)
        form_group_builder(method, options, html_options) do
          prepend_and_append_input(options) do
            @template.select2(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options))
          end
        end
      end
    end

  end
end
