class Api::V1::ExpensesController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_expense, only: [:show, :update, :destroy]
  
  # GET /api/v1/expenses
  def index
    @expenses = current_user.expenses.recent
    
    # Filtros opcionales
    @expenses = @expenses.by_category(params[:category]) if params[:category].present?
    
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      @expenses = @expenses.by_date_range(start_date, end_date)
    end
    
    # Paginación básica
    @expenses = @expenses.page(params[:page]).per(params[:per_page] || 20)
    
    success_response({
      expenses: @expenses.as_json(include: { user: { only: [:id, :email] } }),
      meta: {
        total_count: current_user.expenses.count,
        current_page: params[:page]&.to_i || 1,
        per_page: params[:per_page]&.to_i || 20
      }
    })
  end
  
  # GET /api/v1/expenses/:id
  def show
    success_response(@expense.as_json(include: { user: { only: [:id, :email] } }))
  end
  
  # POST /api/v1/expenses
  def create
    @expense = current_user.expenses.build(expense_params)
    
    if @expense.save
      success_response(
        @expense.as_json(include: { user: { only: [:id, :email] } }),
        'Expense created successfully',
        :created
      )
    else
      error_response('Failed to create expense', @expense.errors.full_messages)
    end
  end
  
  # PUT/PATCH /api/v1/expenses/:id
  def update
    if @expense.update(expense_params)
      success_response(
        @expense.as_json(include: { user: { only: [:id, :email] } }),
        'Expense updated successfully'
      )
    else
      error_response('Failed to update expense', @expense.errors.full_messages)
    end
  end
  
  # DELETE /api/v1/expenses/:id
  def destroy
    if @expense.destroy
      success_response(nil, 'Expense deleted successfully')
    else
      error_response('Failed to delete expense', @expense.errors.full_messages)
    end
  end
  
  # GET /api/v1/expenses/summary
  def summary
    success_response(current_user.expenses_summary)
  end
  
  # GET /api/v1/expenses/categories
  def categories
    categories = current_user.expenses.distinct.pluck(:category).compact.sort
    success_response(categories)
  end
  
  private
  
  def set_expense
    @expense = current_user.expenses.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    error_response('Expense not found', nil, :not_found)
  end
  
  def expense_params
    params.require(:expense).permit(:description, :amount, :date, :category)
  end
end
