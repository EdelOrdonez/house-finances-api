class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.string :description
      t.decimal :amount
      t.date :date
      t.references :user, null: false, foreign_key: true
      t.string :category

      t.timestamps
    end
  end
end
