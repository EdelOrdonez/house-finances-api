class CreateContributions < ActiveRecord::Migration[8.0]
  def change
    create_table :contributions do |t|
      t.references :expense, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :percentage, precision: 5, scale: 2, null: false
      t.decimal :amount_due, precision: 10, scale: 2, null: false

      t.timestamps
    end
    
    add_index :contributions, [:expense_id, :user_id], unique: true
    add_index :contributions, :percentage
    add_index :contributions, :amount_due
  end
end
