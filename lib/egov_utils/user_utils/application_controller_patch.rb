module EgovUtils
  module UserUtils
    module ApplicationControllerPatch

      extend ActiveSupport::Concern

      included do

        before_action :user_setup, :set_locale

        rescue_from CanCan::AccessDenied do |exception|
            respond_to do |format|
              format.json { head :forbidden, content_type: 'text/html' }
              format.html { render template: "errors/error_403", error: exception.message }
              format.js   { head :forbidden, content_type: 'text/html' }
            end
          end

        helper_method :current_user, :internal_network?

      end

      def internal_network?
        request.host.ends_with? 'servis.justice.cz'
      end

      def current_user
        User.current || user_setup
      end

      def user_setup
        # Find the current user
        User.current = find_current_user || User.anonymous
        logger.info("  Current user: " + (User.current.logged? ? "#{User.current.login} (id=#{User.current.id})" : "anonymous")) if logger
        User.current
      end

      def redirect_back(fallback_location:, **args)
        if params[:back_url]
          redirect_to URI.parse(params[:back_url])
        else
          super
        end
      end

      protected
        def find_current_user
          # existing session
          find_session_user if session[:user_id]
        end

        def find_session_user
          User.active.find(session[:user_id])
        rescue ActiveRecord::RecordNotFound => e
          nil
        end

        # Sets the logged in user
        def logged_user=(user)
          reset_session
          if user && user.is_a?(EgovUtils::User)
            User.current = user
            start_user_session(user)
          else
            User.current = User.anonymous
          end
        end

        def start_user_session(user)
          session[:user_id] = user.id
        end

      private
        def set_locale
          I18n.default_locale = :cs
        end

    end
  end
end
