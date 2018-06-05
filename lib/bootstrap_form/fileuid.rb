require 'egov_utils/helpers/tags/fileuid_field'

module BootstrapForm
  module Fileuid

    def fileuid_field(method, options={})
      form_group_builder(method, options) do
        prepend_and_append_input(method, options) do
          @template.fileuid_field(@object_name, method, objectify_options(options))
        end
      end
    end

  end
end
