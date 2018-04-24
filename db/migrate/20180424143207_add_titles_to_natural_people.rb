class AddTitlesToNaturalPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :egov_utils_natural_people, :title, :string
    add_column :egov_utils_natural_people, :higher_title, :string
  end
end
