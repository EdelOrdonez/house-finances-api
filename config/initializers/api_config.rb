# API Configuration
Rails.application.config.after_initialize do
  # Configuración de la API
  API_CONFIG = {
    version: 'v1',
    default_per_page: 20,
    max_per_page: 100,
    supported_categories: [
      'Food', 'Transport', 'Entertainment', 'Shopping', 'Bills', 'Health',
      'Education', 'Travel', 'Home', 'Utilities', 'Insurance', 'Other'
    ]
  }.freeze
  
  # Configuración de paginación
  Kaminari.config.default_per_page = API_CONFIG[:default_per_page]
  Kaminari.config.max_per_page = API_CONFIG[:max_per_page]
end
