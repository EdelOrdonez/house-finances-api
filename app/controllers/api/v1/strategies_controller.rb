class Api::V1::StrategiesController < Api::V1::BaseController
  before_action :authenticate_user!
  
  def index
    @strategies = Strategy.all
    
    render json: {
      status: 'success',
      data: {
        strategies: @strategies.map do |strategy|
          {
            id: strategy.id,
            name: strategy.name,
            description: strategy.description
          }
        end
      }
    }
  end
  
  def show
    @strategy = Strategy.find(params[:id])
    
    render json: {
      status: 'success',
      data: {
        strategy: {
          id: @strategy.id,
          name: @strategy.name,
          description: @strategy.description,
          financial_groups_count: @strategy.financial_groups.count
        }
      }
    }
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: 'error',
      message: 'Estrategia no encontrada'
    }, status: :not_found
  end
end
