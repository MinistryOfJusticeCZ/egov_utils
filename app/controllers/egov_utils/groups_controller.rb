require_dependency "egov_utils/application_controller"

module EgovUtils
  class GroupsController < ApplicationController

    load_and_authorize_resource

    def index
      @groups = EgovUtils::Group.accessible_by(current_ability)
    end

    def show
    end

    def create
      respond_to do |format|
        if @group.save
          format.html{ redirect_to egov_utils.users_path, notice: t('success_created') }
          format.json{ render json: @group, status: :created }
        else
          format.html{ render 'new' }
          format.json{ render json: @group.errors.full_messages, status: :unprocessable_entity }
        end
      end
    end

    def new_users
      @principals = EgovUtils::User.active.assignable_to_group(@group)
      respond_to do |format|
        format.html
        format.js { render_modal_js }
      end
    end

    def add_users
      render_404 and return unless @group.allow_member_assign?
      @users = User.active.assignable_to_group(@group).where(:id => (params[:user_id] || params[:user_ids])).to_a
      @group.users << @users
      respond_to do |format|
        format.html { redirect_to group_path(@group) }
        format.json { head :ok }
      end
    end

    private

      def create_params
        params.require(:group).permit(:name, :provider, :ldap_uid, :external_uid)
      end

  end
end
