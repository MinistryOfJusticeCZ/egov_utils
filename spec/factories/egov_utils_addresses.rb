FactoryBot.define do
  factory :egov_utils_address, class: 'EgovUtils::Address' do
    street 'Vysoka'
    house_number '156'
    orientation_number '6a'
    city 'Palermo'
    postcode 42000
    district 'Hlavní město Praha'
  end

end
