class Api::V1::FinancialGroupsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_financial_group, only: [:show, :update, :destroy, :add_user, :remove_user]
  
  def index
    @financial_groups = current_user.financial_groups.includes(:strategy, :users)
    
    render json: {
      status: 'success',
      data: {
        financial_groups: @financial_groups.map do |group|
          {
            id: group.id,
            name: group.name,
            description: group.description,
            strategy: {
              id: group.strategy.id,
              name: group.strategy.name,
              description: group.strategy.description
            },
            users_count: group.users.count,
            total_income: group.total_income,
            total_expenses: group.total_expenses,
            total_expenses_this_month: group.total_expenses_this_month,
            user_balance: group.user_balance(current_user),
            user_contribution_percentage: group.user_contribution_percentage(current_user)
          }
        end
      }
    }
  end
  
  def show
    render json: {
      status: 'success',
      data: {
        financial_group: {
          id: @financial_group.id,
          name: @financial_group.name,
          description: @financial_group.description,
          strategy: {
            id: @financial_group.strategy.id,
            name: @financial_group.strategy.name,
            description: @financial_group.strategy.description
          },
          users: @financial_group.users.map do |user|
            {
              id: user.id,
              name: user.name,
              email: user.email,
              income: user.income,
              contribution_percentage: @financial_group.user_contribution_percentage(user),
              balance: @financial_group.user_balance(user)
            }
          end,
          expenses: {
            total: @financial_group.total_expenses,
            this_month: @financial_group.total_expenses_this_month,
            by_category: @financial_group.expenses_by_category,
            recent: @financial_group.recent_expenses.map do |expense|
              {
                id: expense.id,
                description: expense.description,
                amount: expense.amount,
                category: expense.category,
                date: expense.date,
                user: {
                  id: expense.user.id,
                  name: expense.user.name
                },
                contributions: expense.contributions_summary
              }
            end
          }
        }
      }
    }
  end
  
  def create
    @financial_group = FinancialGroup.new(financial_group_params)
    @financial_group.strategy = Strategy.find(params[:strategy_id]) if params[:strategy_id]
    
    if @financial_group.save
      @financial_group.add_user(current_user)
      
      render json: {
        status: 'success',
        message: 'Grupo financiero creado exitosamente',
        data: {
          financial_group: {
            id: @financial_group.id,
            name: @financial_group.name,
            description: @financial_group.description,
            strategy: {
              id: @financial_group.strategy.id,
              name: @financial_group.strategy.name
            }
          }
        }
      }, status: :created
    else
      render json: {
        status: 'error',
        message: 'Error al crear el grupo financiero',
        errors: @financial_group.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  def update
    if @financial_group.update(financial_group_params)
      render json: {
        status: 'success',
        message: 'Grupo financiero actualizado exitosamente',
        data: {
          financial_group: {
            id: @financial_group.id,
            name: @financial_group.name,
            description: @financial_group.description
          }
        }
      }
    else
      render json: {
        status: 'error',
        message: 'Error al actualizar el grupo financiero',
        errors: @financial_group.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @financial_group.destroy
      render json: {
        status: 'success',
        message: 'Grupo financiero eliminado exitosamente'
      }
    else
      render json: {
        status: 'error',
        message: 'Error al eliminar el grupo financiero',
        errors: @financial_group.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  def add_user
    user = User.find_by(email: params[:user_email])
    
    unless user
      render json: {
        status: 'error',
        message: 'Usuario no encontrado'
      }, status: :not_found
      return
    end
    
    if @financial_group.add_user(user)
      render json: {
        status: 'success',
        message: 'Usuario agregado al grupo exitosamente',
        data: {
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            income: user.income,
            contribution_percentage: @financial_group.user_contribution_percentage(user)
          }
        }
      }
    else
      render json: {
        status: 'error',
        message: 'Error al agregar usuario al grupo'
      }, status: :unprocessable_entity
    end
  end
  
  def remove_user
    user = User.find(params[:user_id])
    
    if @financial_group.remove_user(user)
      render json: {
        status: 'success',
        message: 'Usuario removido del grupo exitosamente'
      }
    else
      render json: {
        status: 'error',
        message: 'Error al remover usuario del grupo'
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_financial_group
    @financial_group = current_user.financial_groups.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'Grupo financiero no encontrado'
    }, status: :not_found
  end
  
  def financial_group_params
    params.require(:financial_group).permit(:name, :description, :strategy_id)
  end
end
