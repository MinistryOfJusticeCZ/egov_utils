class RenamePeopleToNaturalPeople < ActiveRecord::Migration[5.1]
  def up
    rename_table :egov_utils_people, :egov_utils_natural_people
  end

  def down
    rename_table :egov_utils_natural_people, :egov_utils_people
  end
end
