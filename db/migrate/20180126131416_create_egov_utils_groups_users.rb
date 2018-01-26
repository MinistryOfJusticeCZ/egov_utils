class CreateEgovUtilsGroupsUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :egov_utils_groups_users do |t|
      t.references :group, foreign_key: {to_table: :egov_utils_groups}
      t.references :user, foreign_key: {to_table: :egov_utils_users}
    end
  end
end
