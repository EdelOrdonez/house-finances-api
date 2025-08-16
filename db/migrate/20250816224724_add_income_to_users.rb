class AddIncomeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :income, :decimal, precision: 10, scale: 2, default: 0.0
    add_index :users, :income
  end
end
