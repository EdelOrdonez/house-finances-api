class Contribution < ApplicationRecord
  belongs_to :expense
  belongs_to :user
  
  validates :percentage, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :amount_due, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :expense_id, uniqueness: { scope: :user_id, message: "ya tiene una contribución para este usuario" }
  
  # Scopes útiles
  scope :by_user, ->(user) { where(user: user) }
  scope :by_group, ->(group) { joins(:expense).where(expenses: { financial_group_id: group.id }) }
  scope :this_month, -> { joins(:expense).where(expenses: { date: Date.current.beginning_of_month..Date.current.end_of_month }) }
  
  # Métodos de instancia
  def formatted_percentage
    "#{percentage}%"
  end
  
  def formatted_amount_due
    "%.2f" % amount_due
  end
  
  def is_paid?
    # Aquí podrías agregar lógica para marcar contribuciones como pagadas
    # Por ahora, todas se consideran pendientes
    false
  end
  
  # Callbacks
  before_validation :calculate_amount_due, if: :percentage_changed?
  
  private
  
  def calculate_amount_due
    return unless expense && percentage
    
    self.amount_due = (expense.amount * percentage / 100).round(2)
  end
end
