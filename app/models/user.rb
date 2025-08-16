class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  has_many :expenses, dependent: :destroy
  
  # Validaciones básicas
  validates :email, presence: true, uniqueness: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  
  # Scopes útiles
  scope :active, -> { where.not(encrypted_password: nil) }
  
  # Métodos de instancia
  def total_expenses
    expenses.sum(:amount)
  end
  
  def expenses_by_category
    expenses.group(:category).sum(:amount)
  end
  
  def monthly_expenses(year = Date.current.year, month = Date.current.month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    expenses.by_date_range(start_date, end_date).sum(:amount)
  end
  
  def expenses_summary
    {
      total_expenses: total_expenses,
      total_count: expenses.count,
      by_category: expenses_by_category,
      this_month: monthly_expenses
    }
  end
end
