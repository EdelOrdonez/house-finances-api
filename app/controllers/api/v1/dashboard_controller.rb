class Api::V1::DashboardController < Api::V1::BaseController
  before_action :authenticate_user!
  
  def index
    user = current_user
    
    dashboard_data = {
      user: {
        id: user.id,
        email: user.email
      },
      summary: {
        total_expenses: user.total_expenses,
        total_count: user.expenses.count,
        this_month: user.monthly_expenses,
        by_category: user.expenses_by_category
      },
      recent_expenses: user.expenses.recent.limit(5).map do |expense|
        {
          id: expense.id,
          description: expense.description,
          amount: expense.amount,
          category: expense.category,
          date: expense.date,
          formatted_amount: expense.formatted_amount,
          category_with_emoji: expense.category_with_emoji
        }
      end
    }
    
    render json: {
      status: 'success',
      data: dashboard_data
    }
  end
end
