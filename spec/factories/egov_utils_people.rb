FactoryBot.define do
  factory :egov_utils_person, class: 'EgovUtils::Person' do
    transient do
      natural_attributes { Hash.new }
    end
    association :residence, factory: :egov_utils_address
    joid { SecureRandom.uuid }
    person_type { nil }
    natural_person { nil }
    legal_person { nil }

    trait :natural do
      person_type { 'natural' }
      after(:build) do |person, evaluator|
        evaluator.natural_person = FactoryBot.build(:egov_utils_natural_person, evaluator.natural_attributes.merge(person: person))
      end
    end

    factory :natural_person, traits: [:natural]
  end

  factory :egov_utils_natural_person, class: 'EgovUtils::NaturalPerson' do
    firstname { 'John' }
    sequence(:lastname){|n| "Doe-#{n}"}
    birth_date { Date.today - (Random.new.rand(50)+18).years }
    association :person, factory: :egov_utils_person
  end

end
