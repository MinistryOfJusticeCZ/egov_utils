require 'rails_helper'

module EgovUtils
  RSpec.describe Group, type: :model do
    describe '#ldap_users' do

      let(:group) { FactoryGirl.create(:egov_utils_group) }
      let(:user_attrs) {
        [{:dn=>"uid=jt963,ou=ejustice,DC=ejustice,DC=cz", :firstname=>"Jan", :lastname=>"Turon", :mail=>"JTuron@ejustice.cz", :provider=>"main"},
         {:dn=>"uid=mp927,ou=ejustice,DC=ejustice,DC=cz", :firstname=>"Marek", :lastname=>"Plastiak", :mail=>"MPlastiak@ejustice.cz", :provider=>"main"},
         {:dn=>"uid=oe954,ou=ejustice,DC=ejustice,DC=cz", :firstname=>"Ondrej", :lastname=>"Ezr", :mail=>"OEzr@ejustice.cz", :provider=>"main"}]
      }

      it 'finds ldap_members of the group' do
        expect( group.auth_source ).to receive(:group_members).and_return(user_attrs[1..-1])
        expect( group.ldap_members.count ).to eq(2)
      end
    end
  end
end
