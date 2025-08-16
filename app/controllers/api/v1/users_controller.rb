class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate_user!
  
  # GET /api/v1/profile
  def profile
    success_response({
      user: current_user.as_json(only: [:id, :email, :created_at]),
      expenses_summary: current_user.expenses_summary
    })
  end
end
