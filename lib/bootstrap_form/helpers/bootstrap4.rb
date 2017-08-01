module BootstrapForm
  module Helpers
    module Bootstrap4

      def self.included(base)
        base.class_eval do
          alias_method_chain :submit, :bootstrap4
        end
      end

      def submit_with_bootstrap4(name = nil, options = {})
        options.reverse_merge! class: 'btn btn-secondary'
        submit_without_bootstrap4(name, options)
      end

    end
  end
end
