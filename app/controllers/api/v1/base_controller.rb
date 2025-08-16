class Api::V1::BaseController < ApplicationController
  # Deshabilitar CSRF para APIs
  skip_before_action :verify_authenticity_token
  
  # Configurar respuestas JSON
  respond_to :json
  
  # Manejo de errores
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from StandardError, with: :internal_server_error
  
  private
  
  def not_found(exception)
    render json: {
      status: 'error',
      message: 'Resource not found',
      error: exception.message
    }, status: :not_found
  end
  
  def unprocessable_entity(exception)
    render json: {
      status: 'error',
      message: 'Validation failed',
      errors: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end
  
  def bad_request(exception)
    render json: {
      status: 'error',
      message: 'Bad request',
      error: exception.message
    }, status: :bad_request
  end
  
  def internal_server_error(exception)
    render json: {
      status: 'error',
      message: 'Internal server error',
      error: Rails.env.development? ? exception.message : 'Something went wrong'
    }, status: :internal_server_error
  end
  
  # Método helper para respuestas exitosas
  def success_response(data, message = nil, status = :ok)
    response = { status: 'success', data: data }
    response[:message] = message if message.present?
    
    render json: response, status: status
  end
  
  # Método helper para respuestas de error
  def error_response(message, errors = nil, status = :unprocessable_entity)
    response = { status: 'error', message: message }
    response[:errors] = errors if errors.present?
    
    render json: response, status: status
  end
end
