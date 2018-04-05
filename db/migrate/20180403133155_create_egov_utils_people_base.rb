class CreateEgovUtilsPeopleBase < ActiveRecord::Migration[5.1]
  def change
    create_table :egov_utils_people do |t|
      t.integer :person_type
      t.string :joid
      t.references :residence, foreign_key: {to_table: :egov_utils_addresses}
    end
  end
end
