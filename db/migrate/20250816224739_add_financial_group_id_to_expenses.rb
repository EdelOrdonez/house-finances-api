class AddFinancialGroupIdToExpenses < ActiveRecord::Migration[8.0]
  def change
    add_reference :expenses, :financial_group, null: true, foreign_key: true
    # El índice se crea automáticamente con add_reference
  end
end
