# Devise JWT Configuration
Devise.setup do |config|
  # Configuración JWT
  config.jwt do |jwt|
    # Tiempo de expiración del token (24 horas)
    jwt.expiration_time = 24.hours.to_i
    
    # Clave secreta para firmar tokens
    jwt.secret = Rails.application.credentials.secret_key_base
  end
  
  # Configuración de respuesta JSON
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
