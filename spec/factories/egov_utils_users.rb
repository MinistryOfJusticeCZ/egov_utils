FactoryGirl.define do
  factory :egov_utils_user, class: 'EgovUtils::User' do
    firstname "MyString"
    lastname "MyString2"
    sequence(:login) {|n| "user#{n}@example.com"}
    active true
    roles []
  end
end
