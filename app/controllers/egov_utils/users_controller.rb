require_dependency "egov_utils/application_controller"
require_dependency "egov_utils/auth_source"

module EgovUtils
  class UsersController < ApplicationController

    load_and_authorize_resource only: :index

    def index
      providers
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(create_params)
      respond_to do |format|
        if @user.save
          format.html{ redirect_to main_app.root_path, notice: t('success_user_registered') }
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
      authorize!(User, :manage)
      @user.update(active: true)
      redirect_back(fallback_location: @user)
    end

    def search
      results = []
      providers.each do |provider|
        results.concat( provider.search(params[:q]) )
      end if params[:q].present?
      respond_to do |format|
        format.json{ render json: results }
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
