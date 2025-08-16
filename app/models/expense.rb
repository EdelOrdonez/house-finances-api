class Expense < ApplicationRecord
  belongs_to :user
  
  # Validaciones básicas
  validates :description, presence: true, length: { minimum: 3, maximum: 255 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :category, presence: true, length: { maximum: 100 }
  
  # Scopes útiles
  scope :by_category, ->(category) { where(category: category) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :recent, -> { order(date: :desc) }
  
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
end