module EgovUtils
  module Helpers
    module FormHelper

      # Returns an input tag of the "fileuid" type tailored for accessing a specified attribute (identified by +method+) on an object
      # assigned to the template (identified by +object+). Additional options on the input tag can be passed as a
      # hash with +options+.
      def fileuid_field(object_name, method, options = {})
        Tags::FileuidField.new(object_name, method, self, options).render
      end

    end
  end
end
