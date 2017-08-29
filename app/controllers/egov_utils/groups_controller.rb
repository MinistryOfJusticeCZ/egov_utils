require_dependency "egov_utils/application_controller"

module EgovUtils
  class GroupsController < ApplicationController

    load_and_authorize_resource

    def create
      respond_to do |format|
        if @group.save
          format.html{ redirect_to main_app.root_path, notice: t('success_created') }
          format.json{ render json: @group, status: :created }
        else
          format.html{ render 'new' }
          format.json{ render json: @group.errors.full_messages, status: :unprocessable_entity }
        end
      end
    end

    private

      def create_params
        params.require(:group).permit(:name, :provider, :ldap_uid)
      end

  end
end
