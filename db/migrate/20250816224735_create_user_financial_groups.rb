class CreateUserFinancialGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :user_financial_groups do |t|
      t.references :user, null: false, foreign_key: true
      t.references :financial_group, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :user_financial_groups, [:user_id, :financial_group_id], unique: true, name: 'index_user_financial_groups_unique'
  end
end
