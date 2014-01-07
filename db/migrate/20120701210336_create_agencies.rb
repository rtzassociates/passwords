class CreateAgencies < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :name
      t.string :recipients
      t.string :password

      t.timestamps
    end
  end
end
