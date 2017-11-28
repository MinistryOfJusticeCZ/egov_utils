class AddConfirmationCodeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :egov_utils_users, :confirmation_code, :string
  end
end
