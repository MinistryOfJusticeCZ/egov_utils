FactoryGirl.define do
  factory :egov_utils_audit_record, class: 'EgovUtils::AuditRecord' do
    audited nil
    user nil
    notes "MyText"
  end
end
