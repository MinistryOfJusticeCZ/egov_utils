module EgovUtils
  module TestUtils
    module ControllerHelpers

      def default_user(params={})
        user = FactoryGirl.create(:egov_utils_user, params)
        user
      end

      def admin_user
        default_user(roles: ['admin'])
      end

      def basic_user
        default_user(roles: ['user'])
      end

      def anonymous_user
        u = default_user
        allow(user).to receive(:persisted?).and_return(false)
        u
      end

      def sign_in(user = basic_user)
        allow(controller).to receive(:find_current_user).and_return(user)
      end
    end
  end
end
