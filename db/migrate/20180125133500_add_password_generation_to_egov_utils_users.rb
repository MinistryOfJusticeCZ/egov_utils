class AddPasswordGenerationToEgovUtilsUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :egov_utils_users, :must_change_password, :boolean
    add_column :egov_utils_users, :password_changed_at, :datetime
  end
end
