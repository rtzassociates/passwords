class AddMonthAndYearToPasswordLists < ActiveRecord::Migration
  def change
    add_column :password_lists, :month, :string
    add_column :password_lists, :year, :string
  end
end
