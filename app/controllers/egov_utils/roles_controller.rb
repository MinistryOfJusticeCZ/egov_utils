require_dependency "egov_utils/application_controller"

module EgovUtils
  class RolesController < ApplicationController
    def index
      authorize! :manage, User
      authorize! :manage, Group
      @users = User.all
      @groups = Group.all
    end

    def create
      entity = params[:entity_class].safe_constantize.try(:find, params[:id])
      return render_404 unless entity
      authorize! :manage, entity
      entity.roles = params[:roles].map(&:presence).compact if params[:roles].is_a?(Array)
      if entity.save
        respond_to do |format|
          format.json { render json: entity.roles }
        end
      else
        respond_to do |format|
          format.json { render json: entity.errors.full_messages, status: :unprocessable_entity }
        end
      end
    end
  end
end
