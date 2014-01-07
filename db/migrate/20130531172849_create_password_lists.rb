class CreatePasswordLists < ActiveRecord::Migration
  def change
    create_table :password_lists do |t|

      t.timestamps
    end
  end
end
