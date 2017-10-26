FactoryBot.define do
  factory :egov_utils_group, class: 'EgovUtils::Group' do
    name "EgovUsers"
    provider "main"
    ldap_uid 'S-1-5-21-1698188384-1693678267-1543859470-6637'
  end
end
