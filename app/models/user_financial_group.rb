class UserFinancialGroup < ApplicationRecord
  belongs_to :user
  belongs_to :financial_group
  
  validates :user_id, uniqueness: { scope: :financial_group_id, message: "ya pertenece a este grupo" }
  
  # Callbacks
  after_create :update_group_calculations
  after_destroy :update_group_calculations
  
  private
  
  def update_group_calculations
    # Recalcular contribuciones para gastos existentes
    financial_group.expenses.each do |expense|
      expense.recalculate_contributions
    end
  end
end
