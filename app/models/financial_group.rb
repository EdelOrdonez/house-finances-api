class FinancialGroup < ApplicationRecord
  belongs_to :strategy
  has_many :user_financial_groups, dependent: :destroy
  has_many :users, through: :user_financial_groups
  has_many :expenses, dependent: :destroy
  has_many :contributions, through: :expenses
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { maximum: 500 }
  
  # Scopes útiles
  scope :active, -> { joins(:users).distinct }
  scope :by_user, ->(user) { joins(:user_financial_groups).where(user_financial_groups: { user_id: user.id }) }
  
  # Métodos de instancia
  def total_income
    users.sum(:income)
  end
  
  def total_expenses
    expenses.sum(:amount)
  end
  
  def total_expenses_this_month
    start_date = Date.current.beginning_of_month
    end_date = Date.current.end_of_month
    expenses.where(date: start_date..end_date).sum(:amount)
  end
  
  def expenses_by_category
    expenses.group(:category).sum(:amount)
  end
  
  def recent_expenses(limit = 5)
    expenses.order(date: :desc).limit(limit)
  end
  
  def add_user(user)
    return false if users.include?(user)
    
    user_financial_groups.create(user: user)
  end
  
  def remove_user(user)
    user_financial_groups.find_by(user: user)&.destroy
  end
  
  def user_contribution_percentage(user)
    return 0 if total_income.zero?
    
    ((user.income / total_income) * 100).round(2)
  end
  
  def user_contribution_amount(user)
    (total_expenses * user_contribution_percentage(user) / 100).round(2)
  end
  
  def user_balance(user)
    user_paid = expenses.where(user: user).sum(:amount)
    user_owes = user_contribution_amount(user)
    
    (user_paid - user_owes).round(2)
  end
end
