class AddProviderToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :egov_utils_users, :provider, :string
  end
end
