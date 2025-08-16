class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  has_many :expenses, dependent: :destroy
  has_many :user_financial_groups, dependent: :destroy
  has_many :financial_groups, through: :user_financial_groups
  has_many :contributions, dependent: :destroy
  
  # Validaciones básicas
  validates :email, presence: true, uniqueness: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :income, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Scopes útiles
  scope :active, -> { where.not(encrypted_password: nil) }
  scope :with_income, -> { where('income > 0') }
  
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
  
  # Nuevos métodos para finanzas compartidas
  def total_group_expenses
    contributions.sum(:amount_due)
  end
  
  def total_group_expenses_this_month
    contributions.this_month.sum(:amount_due)
  end
  
  def total_financial_obligation
    total_expenses + total_group_expenses
  end
  
  def total_financial_obligation_this_month
    monthly_expenses + total_group_expenses_this_month
  end
  
  def group_expenses_by_category
    contributions.joins(:expense).group('expenses.category').sum(:amount_due)
  end
  
  def financial_summary
    {
      personal: {
        total_expenses: total_expenses,
        total_count: expenses.count,
        by_category: expenses_by_category,
        this_month: monthly_expenses
      },
      shared: {
        total_obligation: total_group_expenses,
        total_obligation_this_month: total_group_expenses_this_month,
        by_category: group_expenses_by_category,
        groups_count: financial_groups.count
      },
      total: {
        total_obligation: total_financial_obligation,
        total_obligation_this_month: total_financial_obligation_this_month
      }
    }
  end
  
  def group_balances
    financial_groups.map do |group|
      {
        group_id: group.id,
        group_name: group.name,
        balance: group.user_balance(self),
        contribution_percentage: group.user_contribution_percentage(self),
        total_paid: expenses.where(financial_group: group).sum(:amount),
        total_owes: group.user_contribution_amount(self)
      }
    end
  end
end
