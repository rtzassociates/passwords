class AddDeliveredAtToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :delivered_at, :string
  end
end
