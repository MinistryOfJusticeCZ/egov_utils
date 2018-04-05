class JoinPeopleTables < ActiveRecord::Migration[5.1]
  def up
    add_reference :egov_utils_natural_people, :person, foreign_key: { to_table: :egov_utils_people }
    select_rows("SELECT id, residence_id FROM egov_utils_natural_people").each do |row|
      if row.second
        value = exec_insert("INSERT INTO egov_utils_people (person_type, residence_id) VALUES (1, #{row.second})", "person create")
      else
        value = exec_insert("INSERT INTO egov_utils_people (person_type) VALUES (1)", "person create")
      end
      id_value = ActiveRecord::Base.connection.send(:last_inserted_id, value)
      execute("UPDATE egov_utils_natural_people SET person_id = #{id_value} WHERE id = #{row.first}")
    end
    # remove_reference :egov_utils_natural_people, :residence
  end

  def down
    add_reference :egov_utils_natural_people, :residence, foreign_key: { to_table: :egov_utils_addresses }
    EgovUtils::NaturalPerson.preload(:person).all.each do |np|
      np.update_column(:residence_id, np.person.residence_id)
    end
    remove_reference :egov_utils_natural_people, :person, foreign_key: { to_table: :egov_utils_people }
  end
end
