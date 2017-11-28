require_dependency "egov_utils/application_controller"
require_dependency "egov_utils/auth_source"

module EgovUtils
  class UsersController < ApplicationController

    skip_before_action :require_login, only: [:new, :create, :confirm]

    load_and_authorize_resource only: :index

    def index
      providers
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(create_params)
      @user.mail ||= @user.login
      respond_to do |format|
        if @user.save
          UserMailer.confirmation_email(@user).deliver_later unless current_user.logged?
          format.html{ redirect_to main_app.root_path, notice: t('activerecord.successful.messages.created', model: User.model_name.human) }
          format.json{ render json: @user, status: :created }
        else
          format.html{ render 'new' }
          format.json{ render json: @user.errors.full_messages, status: :unprocessable_entity }
        end
      end
    end

    def show
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
        params.require(:user).permit(:login, :mail, :password, :password_confirmation, :provider, :firstname, :lastname)
      end
  end
end
