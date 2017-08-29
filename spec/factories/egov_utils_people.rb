FactoryGirl.define do
  factory :egov_utils_person, class: 'EgovUtils::Person' do
    firstname "MyString"
    lastname "MyString"
    birth_date "MyString"
    external_uid "MyString"
  end
end
