module BootstrapForm
  module Helpers
    module Bootstrap4

      def submit(name = nil, options = {})
        options.reverse_merge! class: 'btn btn-secondary'
        super(name, options)
      end


      # TODO check upstream - append tag options
      def prepend_and_append_input(name, options, &block)
        options = options.extract!(:prepend, :append, :input_group_class, :append_tag, :input_group)
        input_group_class = ["input-group", options[:input_group_class]].compact.join(' ')

        input = capture(&block) || "".html_safe

        input = content_tag(:div, input_group_content(options[:prepend]), class: 'input-group-prepend') + input if options[:prepend]
        input << content_tag(:div, input_group_content(options[:append]), (options[:append_tag] || {}).merge(class: 'input-group-append')) if options[:append]
        input << generate_error(name)
        input = content_tag(:div, input, (options[:input_group] || {}).merge(class: input_group_class)) unless options.empty?
        input
      end

    end
  end
end
