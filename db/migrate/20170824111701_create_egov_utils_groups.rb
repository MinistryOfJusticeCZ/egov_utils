class CreateEgovUtilsGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :egov_utils_groups do |t|
      t.string :name
      t.string :provider
      t.string :roles
      t.string :ldap_uid

      t.timestamps
    end
  end
end
