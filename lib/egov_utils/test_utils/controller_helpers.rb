module EgovUtils
  module TestUtils
    module ControllerHelpers

      attr_reader :signed_user

      def default_user(params={})
        user = FactoryBot.create(:egov_utils_user, params)
        user
      end

      def admin_user
        default_user(roles: ['admin'])
      end

      def basic_user
        default_user(roles: ['user'])
      end

      def anonymous_user
        user = default_user
        allow(user).to receive(:persisted?).and_return(false)
        user
      end

      def sign_in(user = basic_user)
        @signed_user = user
        allow(controller).to receive(:find_current_user).and_return(user)
      end
    end
  end
end
