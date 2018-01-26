require_dependency "egov_utils/application_controller"

module EgovUtils
  class PasswordsController < ApplicationController

    skip_before_action :check_password_change

    def edit
      @user = current_user
    end

    def update
      @user = current_user
      if @user.password_change_possible? && @user.password_check?(params[:password_change][:current_password])
        @user.attributes = password_change_params
        @user.must_change_password = false
      end
      if @user.save
        flash[:notice] = t(:notice_password_changed)
        redirect_to main_app.root_path
      else
        flash[:warning] = t(:warning_password_not_changed)
        redirect_to edit_password_path(@user)
      end
    end

    private

      def password_change_params
        params.require(:password_change).permit(:password, :password_confirmation)
      end

  end
end
