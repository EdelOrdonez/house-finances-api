class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Configurar respuestas JSON por defecto
  respond_to :html, :json
  
  # Manejo de errores para HTML
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request
  
  private
  
  def not_found(exception)
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false }
      format.json { render json: { error: 'Not found' }, status: :not_found }
    end
  end
  
  def bad_request(exception)
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/400.html", status: :bad_request, layout: false }
      format.json { render json: { error: 'Bad request' }, status: :bad_request }
    end
  end
end
