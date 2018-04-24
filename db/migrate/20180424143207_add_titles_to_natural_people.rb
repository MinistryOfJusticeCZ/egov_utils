class AddTitlesToNaturalPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :natural_people, :title, :string
    add_column :natural_people, :higher_title, :string
  end
end
