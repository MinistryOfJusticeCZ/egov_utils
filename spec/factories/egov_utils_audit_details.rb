FactoryGirl.define do
  factory :egov_utils_audit_detail, class: 'EgovUtils::AuditDetail' do
    audit_record nil
    property "MyString"
    prop_key "MyString"
    old_value "MyText"
    value "MyText"
  end
end
