class CreateEgovUtilsAuditRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :egov_utils_audit_records do |t|
      t.references :audited, foreign_key: true
      t.references :user, foreign_key: true
      t.text :notes

      t.timestamps
    end
  end
end
