module EgovUtils
  class PeopleController < ApplicationController

    load_and_authorize_resource

    def index
      @people_schema = PersonSchema.new
      @people_schema.from_params(params)
      respond_to do |format|
        if params['_type'] == 'query'
          format.json{ render json: {
            results: @people_schema.entities.collect do |p|
                {id: p.id, text: p.to_s, residence: p.residence.to_s}
              end
          }}
        else
          format.json{ render json: @people_schema }
        end
      end
    end

  end
end
