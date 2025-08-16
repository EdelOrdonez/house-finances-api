class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist
  
  self.table_name = 'jwt_denylists'
  
  # Validaciones básicas
  validates :jti, presence: true, uniqueness: true
  validates :exp, presence: true
  
  # Scopes útiles
  scope :expired, -> { where('exp < ?', Time.current) }
  scope :active, -> { where('exp > ?', Time.current) }
  
  # Métodos de instancia
  def expired?
    exp < Time.current
  end
  
  def active?
    exp > Time.current
  end
  
  # Método de clase para limpiar tokens expirados
  def self.cleanup_expired
    expired.delete_all
  end
end
  