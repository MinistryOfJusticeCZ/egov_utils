require 'rails_helper'

module EgovUtils
  RSpec.describe Group, type: :model do

    let(:user_attrs) {
      [{:dn=>"uid=jt963,ou=ejustice,DC=ejustice,DC=cz", :firstname=>"Jan", :lastname=>"Turon", :mail=>"JTuron@ejustice.cz", :login=>"JTuron@ejustice.cz", :provider=>"main"},
       {:dn=>"uid=mp927,ou=ejustice,DC=ejustice,DC=cz", :firstname=>"Marek", :lastname=>"Plastiak", :mail=>"MPlastiak@ejustice.cz", :login=>"MPlastiak@ejustice.cz", :provider=>"main"},
       {:dn=>"uid=oe954,ou=ejustice,DC=ejustice,DC=cz", :firstname=>"Ondrej", :lastname=>"Ezr", :mail=>"OEzr@ejustice.cz", :login=>"OEzr@ejustice.cz", :provider=>"main"}]
    }

    describe '#ldap_users' do

      let(:group) { FactoryBot.create(:egov_utils_group) }

      it 'finds ldap_members of the group' do
        expect( group.auth_source ).to receive(:group_members).and_return(user_attrs[1..-1])
        expect( group.ldap_members.count ).to eq(2)
      end
    end

    describe 'roles' do
      let(:group) { FactoryBot.create(:egov_utils_group, roles: ['admin']) }
      let(:user) { FactoryBot.create(:egov_utils_user, user_attrs.last.except(:dn)) }
      it 'sets roles to user' do
        expect( user ).to receive(:ldap_groups).at_least(:once).and_return([group])
        expect( user.groups ).to include( group )
        expect( user.all_role_names ).to include('admin')
      end
    end
  end
end
