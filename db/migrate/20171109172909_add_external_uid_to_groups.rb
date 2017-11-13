class AddExternalUidToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :egov_utils_groups, :external_uid, :string
  end
end
