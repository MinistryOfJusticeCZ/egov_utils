require 'rails_helper'

module EgovUtils
  RSpec.describe GroupsController, type: :controller do
    routes { EgovUtils::Engine.routes }

    describe '#create', logged: :admin do
      let(:ldap_attrs){ {"dn"=>"cn=Egov Users,ou=Groups,DC=ejustice,DC=cz", "name"=>"EgovUsers", "provider"=>"main", "ldap_uid"=>'S-1-5-21-1698188384-1693678267-1543859470-6637'} }

      it 'create group from ldap' do
        post :create, params: {format: :json}.merge(group: ldap_attrs)
        expect(Group.count).to eq(1)
      end
    end
  end
end
