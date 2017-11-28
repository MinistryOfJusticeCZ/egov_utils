FactoryBot.define do
  factory :egov_utils_user, class: 'EgovUtils::User' do
    firstname "John"
    lastname "Doe"
    sequence(:login) {|n| "user#{n}@example.com"}
    password 'abcdef123456'
    password_confirmation 'abcdef123456'
    active true
    roles []
  end
end
