class CreateEgovUtilsPeople < ActiveRecord::Migration[5.1]
  def change
    create_table :egov_utils_people do |t|
      t.string :firstname
      t.string :lastname
      t.date :birth_date
      t.string :external_uid

      t.timestamps
    end
  end
end
