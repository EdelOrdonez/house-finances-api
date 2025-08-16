class Strategy < ApplicationRecord
  has_many :financial_groups, dependent: :restrict_with_error
  
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  
  # Estrategia por defecto
  scope :default, -> { find_by(name: 'Proportional') }
  
  # Método para calcular contribuciones según la estrategia
  def calculate_contributions(expense)
    case name.downcase
    when 'proportional'
      calculate_proportional_contributions(expense)
    when 'equal'
      calculate_equal_contributions(expense)
    else
      raise "Estrategia no soportada: #{name}"
    end
  end
  
  private
  
  def calculate_proportional_contributions(expense)
    group = expense.financial_group
    users = group.users
    
    total_income = users.sum(:income)
    return [] if total_income.zero?
    
    contributions = []
    
    users.each do |user|
      percentage = (user.income / total_income * 100).round(2)
      amount_due = (expense.amount * percentage / 100).round(2)
      
      contributions << {
        user_id: user.id,
        percentage: percentage,
        amount_due: amount_due
      }
    end
    
    contributions
  end
  
  def calculate_equal_contributions(expense)
    group = expense.financial_group
    users = group.users
    user_count = users.count
    
    return [] if user_count.zero?
    
    equal_amount = (expense.amount / user_count).round(2)
    equal_percentage = (100.0 / user_count).round(2)
    
    users.map do |user|
      {
        user_id: user.id,
        percentage: equal_percentage,
        amount_due: equal_amount
      }
    end
  end
end
