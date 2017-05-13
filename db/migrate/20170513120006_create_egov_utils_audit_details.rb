class CreateEgovUtilsAuditDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :egov_utils_audit_details do |t|
      t.references :audit_record, foreign_key: true
      t.string :property
      t.string :prop_key
      t.text :old_value
      t.text :value

      t.timestamps
    end
  end
end
