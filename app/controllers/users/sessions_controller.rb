class Users::SessionsController < Devise::SessionsController
  # Deshabilitar CSRF para APIs
  skip_before_action :verify_authenticity_token
  
  # Configurar respuestas JSON
  respond_to :json
  
  private
  
  def respond_with(resource, _opts = {})
    if resource.persisted?
      # Generar token JWT usando Devise JWT
      token = request.env['warden-jwt_auth.token']
      
      render json: {
        status: 'success',
        message: 'Signed in successfully',
        data: {
          user: {
            id: resource.id,
            email: resource.email
          },
          token: token
        }
      }
    else
      render json: {
        status: 'error',
        message: 'Invalid email or password'
      }, status: :unauthorized
    end
  end
  
  def respond_to_on_destroy
    if current_user
      render json: {
        status: 'success',
        message: 'Signed out successfully'
      }
    else
      render json: {
        status: 'error',
        message: 'No user signed in'
      }, status: :unauthorized
    end
  end
end
