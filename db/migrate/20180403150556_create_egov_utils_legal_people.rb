class CreateEgovUtilsLegalPeople < ActiveRecord::Migration[5.1]
  def change
    create_table :egov_utils_legal_people do |t|
      t.references :person, foreign_key: { to_table: :egov_utils_people }
      t.string :name
      t.string :ico
      t.integer :legal_form
    end
  end
end
