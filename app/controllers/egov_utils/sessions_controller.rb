module EgovUtils
  class SessionsController < ApplicationController

    def new
      if current_user.logged?
        redirect_to main_app.root_path
      end
    end

    def create
      password_authentication
    end

    def destroy
      reset_session
      redirect_to login_path, notice: t(:notice_logout)
    end

    private
      def password_authentication
        user = User.authenticate(params[:session][:username], params[:session][:password], false)

        if user.nil?
          invalid_credentials
        elsif user.new_record?
          onthefly_creation_failed(user, {:login => user.login, :provider => user.provider })
        else
          # Valid user
          if user.active?
            successful_authentication(user)
          else
            handle_inactive_user(user)
          end
        end
      end

      def invalid_credentials(redirect_path=signin_path)
        logger.warn "Failed login for '#{params[:session][:username]}' from #{request.remote_ip} at #{Time.now.utc}"
        flash[:error] = t(:notice_account_invalid_credentials)
        redirect_to redirect_path
      end

      def successful_authentication(user)
        logger.info "Successful authentication for '#{user.login}' from #{request.remote_ip} at #{Time.now.utc}"
        # Valid user
        self.logged_user = user
        # generate a key and set cookie if autologin
        if params[:autologin]
          set_autologin_cookie(user)
        end
        redirect_to main_app.root_path
        # redirect_back(fallback_location: root_path)
      end

      def handle_inactive_user(user, redirect_path=signin_path)
        if user.locked?
          account_locked(user, redirect_path)
        else
          account_pending(user, redirect_path)
        end
      end

      def account_pending(user, redirect_path=signin_path)
        flash[:error] = t(:notice_account_pending)
        redirect_to redirect_path
      end

      def account_locked(user, redirect_path=signin_path)
        flash[:error] = t(:notice_account_locked)
        redirect_to redirect_path
      end

  end
end
