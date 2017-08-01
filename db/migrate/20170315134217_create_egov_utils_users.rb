class CreateEgovUtilsUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :egov_utils_users do |t|
      t.string :login
      t.string :mail
      t.string :password_digest
      t.string :firstname
      t.string :lastname
      t.boolean :active, default: false
      t.string :roles
      t.datetime :last_login_at

      t.timestamps
    end
  end
end
