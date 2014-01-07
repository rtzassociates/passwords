class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.integer :password_list_id
      t.datetime :deliver_at
      t.integer :job_id
      t.timestamps
    end
  end
end
