class AddBirthPlaceAndResidenceToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :egov_utils_people, :birth_place, :string
    add_reference :egov_utils_people, :residence, foreign_key: {to_table: :egov_utils_addresses}
  end
end
