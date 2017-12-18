module EgovUtils
  class OrganizationsController < ApplicationController

    def district_courts
      ids = params[:ids]
      render json: Organization.district_courts([ids].flatten).collect{|o| o.id }
    end

  end
end
