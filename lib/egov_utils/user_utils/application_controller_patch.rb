module EgovUtils
  module UserUtils
    module ApplicationControllerPatch

      extend ActiveSupport::Concern

      included do

        before_action :user_setup, :set_locale
        before_action :require_login, :check_password_change

        rescue_from CanCan::AccessDenied do |exception|
            respond_to do |format|
              format.json { head :forbidden, content_type: 'text/html' }
              format.html { render template: "errors/error_403", error: exception.message, status: 403 }
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
        User.current = find_current_user || find_kerberos_user || User.anonymous
        logger.info("  Current user: " + (User.current.logged? ? "#{User.current.login} (id=#{User.current.id})(roles=#{User.current.all_role_names.join(',')})" : "anonymous")) if logger
        User.current
      end

      def redirect_back(fallback_location:, **args)
        if params[:back_url]
          redirect_to URI.parse(params[:back_url])
        else
          super
        end
      end

      def render_modal_js(**options)
        @partial_scope = options[:scope] || params[:controller]
        @action = options[:action] || params[:action]
        render 'common/modal_action'
      end

      def render_404(exception = nil)
        respond_to do |format|
          format.json { head :not_found, content_type: 'text/html' }
          format.html { render template: "errors/error_404", error: exception.try('message'), status: 404 }
          format.js   { head :not_found, content_type: 'text/html' }
        end
        return false
      end

      def editable_attributes(model, action=:update)
        EgovUtils::ModelPermissions.build(model, current_ability).editable_attributes(action)
      end

      def editable_attributes_for(entity, action=:update)
        EgovUtils::ModelPermissions.build(entity.type, current_ability).editable_attributes_for(entity, action)
      end

      protected
        def find_current_user
          # existing session
          find_session_user if session[:user_id]
        end

        def find_kerberos_user
          return nil unless internal_network? && EgovUtils::AuthSource.kerberos_providers.any? && request.env['HTTP_REMOTE_USER'].present?
          username = request.env['HTTP_REMOTE_USER'].split('@')[0]
          logger.info("  Trying kerberos: #{username}") if logger
          attrs = EgovUtils::AuthSource.find_kerberos_user(username)
          if attrs
            user = User.active.find_by(login: attrs[:login])
            logger.info("  Found kerberos user: #{attrs[:login]} and it is in database") if logger && user
            logged_user = user
            user
          end
        end


        def find_session_user
          User.active.find(session[:user_id])
        rescue ActiveRecord::RecordNotFound => e
          nil
        end

        # Sets the logged in user
        def logged_user=(user)
          reset_session
          if user && user.is_a?(EgovUtils::User) && user.active?
            User.current = user
            start_user_session(user)
          else
            User.current = User.anonymous
          end
        end

        def start_user_session(user)
          session[:user_id] = user.id
        end

        def require_login
          if require_login? && !current_user.logged?
            # Extract only the basic url parameters on non-GET requests
            if request.get?
              url = request.original_url
            else
              url = url_for(:controller => params[:controller], :action => params[:action], :id => params[:id], only_path: true)
            end
            respond_to do |format|
              format.html {
                if request.xhr?
                  head :unauthorized
                else
                  redirect_to egov_utils.login_path(:back_url => url)
                end
              }
              format.any(:atom, :pdf, :csv) {
                redirect_to egov_utils.login_path(:back_url => url)
              }
              format.xml  { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="'+t(:app_abbrev)+'"' }
              format.js   { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="'+t(:app_abbrev)+'"' }
              format.json { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="'+t(:app_abbrev)+'"' }
              format.any  { head :unauthorized }
            end
            return false
          end
          true
        end

        def check_password_change
          if current_user.logged? && current_user.must_change_password?
            respond_to do |format|
              format.html {
                flash[:error] = t(:error_password_expired)
                redirect_to egov_utils.edit_password_path(current_user)
              }
              format.json { render json: { error: t(:error_password_expired) }, status: :unauthorized }
            end
          end
        end

        def require_login?
          false
        end

      private
        def set_locale
          I18n.default_locale = :cs
        end

    end
  end
end
