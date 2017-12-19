module BootstrapForm
  module Helpers
    module Bootstrap4

      def submit(name = nil, options = {})
        options.reverse_merge! class: 'btn btn-secondary'
        pp options
        super(name, options)
      end

    end
  end
end
