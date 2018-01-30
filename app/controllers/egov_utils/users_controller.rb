require_dependency "egov_utils/application_controller"
require_dependency "egov_utils/auth_source"

module EgovUtils
  class UsersController < ApplicationController

    skip_before_action :require_login, only: [:new, :create, :confirm]

    authorize_resource only: :index
    load_and_authorize_resource only: :destroy

    def index
      providers
      @users = EgovUtils::User.accessible_by(current_ability).order(:provider)
      @groups = EgovUtils::Group.accessible_by(current_ability).order(:provider)
      @new_user = EgovUtils::User.new(generate_password: true)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(create_params)
      @user.mail ||= @user.login
      respond_to do |format|
        if @user.save
          if EgovUtils::Settings.allow_register? && !current_user.logged?
            UserMailer.confirmation_email(@user).deliver_later
            flash[:notice] = t('notice_signeup_with_mail')
          else
            if @user.auth_source.nil?
              @user.update(active: true)
              UserMailer.account_information(@user, @user.password).deliver_later
            end
            flash[:notice] = t('activerecord.successful.messages.created', model: User.model_name.human)
          end
          format.html{ redirect_to main_app.root_path }
          format.json{ render json: @user, status: :created }
        else
          format.html{ render 'new' }
          format.json{ render json: @user.errors.full_messages, status: :unprocessable_entity }
        end
      end
    end

    def show
    end

    def destroy
      @user.destroy
      redirect_to users_path, notice: t('activerecord.successful.messages.destroyed', model: User.model_name.human)
    end

    def approve
      @user = User.find_by(id: params[:id])
      render_404 and return unless @user || @user.active?
      authorize!(:manage, User)
      @user.update(active: true)
      redirect_back(fallback_location: @user)
    end

    def confirm
      @user = User.find_by(confirmation_code: params[:id])
      render_404 and return unless @user || @user.active? || @user.updated_at < (Time.now - 24.hours)
      @user.update(active: true)
      logged_user = @user
      flash[:notice] = t('success_user_confirm')
      redirect_to('/')
    end

    def search
      authorize!(:read, User)
      authorize!(:read, Group)
      user_results = []; group_results = []
      providers.each do |provider|
        user_results.concat( provider.search_user(params[:q]) )
        group_results.concat( provider.search_group(params[:q]) )
      end if params[:q].present?
      respond_to do |format|
        format.json{ render json: {users: user_results, groups: group_results} }
      end
    end

    private

      def providers
         @providers = EgovUtils::AuthSource.providers.collect{|p| EgovUtils::AuthSource.new(p)}
      end

      def create_params
        params_to_permit = [:login, :mail, :password, :password_confirmation, :provider, :firstname, :lastname]
        params_to_permit << :generate_password if current_user.logged?
        params.require(:user).permit(*params_to_permit)
      end
  end
end
