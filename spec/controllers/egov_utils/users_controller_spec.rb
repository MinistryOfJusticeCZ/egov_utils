require 'rails_helper'

module EgovUtils
  RSpec.describe UsersController, type: :controller do
    routes { EgovUtils::Engine.routes }

    let(:ldap_attrs){ {"dn"=>"cn=Egov Users,ou=Groups,DC=ejustice,DC=cz", "name"=>"EgovUsers", "provider"=>"main", "ldap_uid"=>'S-1-5-21-1698188384-1693678267-1543859470-6637'} }

    describe 'search ldap', ldap: true, logged: :admin do
      it 'dont allow users to browse ldap', logged: true do
        get :search, params: { format: :json, q: 'Egov' }
        expect(response).to have_http_status(:forbidden)
      end


      it 'finds ldap group' do
        # expect(EgovUtils::AuthSource).to receive(:msg).with(*args)
        get :search, params: { format: :json, q: 'Egov' }
        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json['groups']).not_to be_empty
        expect(json['groups'].first['name']).to eq('EgovUsers')
      end
    end


  end
end
