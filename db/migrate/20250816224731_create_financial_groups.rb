class CreateFinancialGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :financial_groups do |t|
      t.string :name, null: false
      t.text :description
      t.references :strategy, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :financial_groups, :name
  end
end
