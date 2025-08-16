class AddIndexesToExpenses < ActiveRecord::Migration[8.0]
  def change
    # Índice compuesto para búsquedas por usuario y fecha
    add_index :expenses, [:user_id, :date]
    
    # Índice para búsquedas por categoría
    add_index :expenses, :category
    
    # Índice para búsquedas por monto (útil para reportes)
    add_index :expenses, :amount
    
    # Índice compuesto para búsquedas por usuario y categoría
    add_index :expenses, [:user_id, :category]
  end
end
