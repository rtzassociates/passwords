class AddPasswordListIdToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :password_list_id, :integer
  end
end
