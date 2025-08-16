class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :financial_group, optional: true
  has_many :contributions, dependent: :destroy
  
  # Validaciones básicas
  validates :description, presence: true, length: { minimum: 3, maximum: 255 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :category, presence: true, length: { maximum: 100 }
  
  # Scopes útiles
  scope :by_category, ->(category) { where(category: category) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :recent, -> { order(date: :desc) }
  scope :personal, -> { where(financial_group_id: nil) }
  scope :shared, -> { where.not(financial_group_id: nil) }
  scope :by_group, ->(group) { where(financial_group: group) }
  
  # Callbacks
  after_create :create_contributions, if: :shared_expense?
  after_update :update_contributions, if: :shared_expense?
  after_destroy :destroy_contributions, if: :shared_expense?
  
  # Métodos de instancia
  def formatted_amount
    "%.2f" % amount
  end
  
  def category_with_emoji
    case category&.downcase
    when 'food'
      '🍽️ Food'
    when 'transport'
      '🚗 Transport'
    when 'entertainment'
      '🎬 Entertainment'
    when 'shopping'
      '🛍️ Shopping'
    when 'bills'
      '📄 Bills'
    when 'health'
      '🏥 Health'
    else
      category
    end
  end
  
  def shared_expense?
    financial_group_id.present?
  end
  
  def personal_expense?
    financial_group_id.nil?
  end
  
  def group_name
    financial_group&.name || 'Personal'
  end
  
  # Métodos para contribuciones
  def create_contributions
    return unless financial_group&.strategy
    
    strategy = financial_group.strategy
    contribution_data = strategy.calculate_contributions(self)
    
    contribution_data.each do |data|
      contributions.create!(
        user_id: data[:user_id],
        percentage: data[:percentage],
        amount_due: data[:amount_due]
      )
    end
  end
  
  def update_contributions
    return unless shared_expense?
    
    # Destruir contribuciones existentes y recrearlas
    contributions.destroy_all
    create_contributions
  end
  
  def destroy_contributions
    contributions.destroy_all
  end
  
  def recalculate_contributions
    update_contributions
  end
  
  def total_contributions
    contributions.sum(:amount_due)
  end
  
  def contributions_summary
    contributions.includes(:user).map do |contribution|
      {
        user_id: contribution.user_id,
        user_name: contribution.user.name,
        percentage: contribution.percentage,
        amount_due: contribution.amount_due,
        formatted_percentage: contribution.formatted_percentage,
        formatted_amount_due: contribution.formatted_amount_due
      }
    end
  end
end