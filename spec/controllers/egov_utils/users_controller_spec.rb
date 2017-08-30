require 'rails_helper'

module EgovUtils
  RSpec.describe UsersController, type: :controller do
    routes { EgovUtils::Engine.routes }

    describe 'search ldap', ldap: true, logged: :admin do
      it 'dont allow users to browse ldap', logged: true do
        get :search, params: { format: :json, q: 'Egov' }
        expect(response).to have_http_status(:forbidden)
      end

      it 'finds ldap group' do
        get :search, params: { format: :json, q: 'Egov' }
        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json['groups']).not_to be_empty
        expect(json['groups'].first['name']).to eq('EgovUsers')
      end
    end


  end
end
