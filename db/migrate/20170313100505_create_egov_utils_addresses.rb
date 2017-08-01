class CreateEgovUtilsAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :egov_utils_addresses do |t|
      t.integer :egov_identifier
      t.string :street
      t.string :house_number
      t.string :orientation_number
      t.string :city
      t.string :city_part
      t.string :postcode
      t.string :district
      t.string :region
      t.string :country

      t.timestamps
    end
  end
end
