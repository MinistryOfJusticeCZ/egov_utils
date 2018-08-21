require_dependency "egov_utils/application_controller"

module EgovUtils
  class PasswordsController < ApplicationController

    skip_before_action :require_login, only: [:reset, :send_reset_token, :new, :create]
    skip_before_action :check_password_change, only: [:edit, :update]

    before_action :find_user_for_reset, only: [:new, :create]

    def reset
      return render_404 unless EgovUtils::Settings.allow_password_reset?
    end

    def send_reset_token
      return render_404 unless EgovUtils::Settings.allow_password_reset?
      @user = EgovUtils::User.find_by(mail: params[:reset_password][:mail])
      if @user && @user.password_change_possible?
        @token = @user.generate_reset_password_token
        EgovUtils::UserMailer.with(host: mailer_host).password_reset(@user, @token).deliver_later # if @user.save
      end
      redirect_to egov_utils.reset_passwords_path, notice: t('notice_reset_email_sent')
    end

    # New password for existing user - password reset
    def new
    end
    def create
      if change_password!(@user)
        EgovUtils::UserMailer.with(host: mailer_host).password_change_info(@user).deliver_later
        flash[:notice] = t(:notice_password_changed)
        redirect_to main_app.root_path
      else
        flash[:warning] = t(:warning_password_not_changed)
        redirect_to reset_passwords
      end
    end

    def edit
      @user = current_user
    end

    def update
      @user = current_user
      if @user.password_check?(params[:password_change][:current_password]) && change_password!(@user)
        EgovUtils::UserMailer.password_change_info(@user).deliver_later
        flash[:notice] = t(:notice_password_changed)
        redirect_to main_app.root_path
      else
        flash[:warning] = t(:warning_password_not_changed)
        redirect_to edit_password_path(@user)
      end
    end

    private

      def find_user_for_reset
        @token = params[:token]
        @user = EgovUtils::User.find_by(confirmation_code: @token)
        if @user.nil? || @user.updated_at < (Time.now - 1.hour)
          render_404
        else
          @user
        end
      end

      def password_change_params
        params.require(:password_change).permit(:password, :password_confirmation)
      end

      # private helpers
      def change_password!(user)
        return false unless @user.password_change_possible?
        user.attributes = password_change_params
        user.must_change_password = false
        user.save
      end

  end
end
