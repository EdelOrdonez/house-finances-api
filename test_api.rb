#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'
require 'date'

# Configuración
BASE_URL = 'http://localhost:3000'
API_BASE = "#{BASE_URL}/api/v1"

# Función para hacer peticiones HTTP
def make_request(method, url, data = nil, headers = {})
  uri = URI(url)
  
  case method.upcase
  when 'GET'
    request = Net::HTTP::Get.new(uri)
  when 'POST'
    request = Net::HTTP::Post.new(uri)
  when 'PUT'
    request = Net::HTTP::Put.new(uri)
  when 'DELETE'
    request = Net::HTTP::Delete.new(uri)
  end
  
  # Headers por defecto
  request['Content-Type'] = 'application/json'
  headers.each { |key, value| request[key] = value }
  
  # Agregar datos si es POST/PUT
  request.body = data.to_json if data && ['POST', 'PUT'].include?(method.upcase)
  
  # Hacer la petición
  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end
  
  puts "=== #{method.upcase} #{url} ==="
  puts "Status: #{response.code} #{response.message}"
  puts "Response: #{response.body}"
  puts "=" * 50
  
  response
rescue => e
  puts "Error: #{e.message}"
  nil
end

# Función para login
def login(email, password)
  data = {
    user: {
      email: email,
      password: password
    }
  }
  
  response = make_request('POST', "#{BASE_URL}/users/sign_in", data)
  
  if response&.code == '200'
    begin
      json_response = JSON.parse(response.body)
      token = json_response.dig('data', 'token')
      puts "✅ Login exitoso. Token: #{token ? token[0..20] + '...' : 'No token'}"
      return token
    rescue JSON::ParserError
      puts "❌ Error parsing JSON response"
      return nil
    end
  else
    puts "❌ Login falló"
    return nil
  end
end

# Función para probar endpoints protegidos
def test_protected_endpoints(token)
  return unless token
  
  headers = { 'Authorization' => "Bearer #{token}" }
  
  puts "\n🔒 Probando endpoints protegidos..."
  
  # Listar gastos
  make_request('GET', "#{API_BASE}/expenses", nil, headers)
  
  # Obtener perfil
  make_request('GET', "#{API_BASE}/profile", nil, headers)
  
  # Obtener resumen
  make_request('GET', "#{API_BASE}/expenses/summary", nil, headers)
  
  # Obtener categorías
  make_request('GET', "#{API_BASE}/expenses/categories", nil, headers)
end

# Función para crear un gasto de prueba
def create_test_expense(token)
  return unless token
  
  headers = { 'Authorization' => "Bearer #{token}" }
  
  data = {
    expense: {
      description: "Gasto de prueba desde script",
      amount: 99.99,
      date: Date.today.to_s,
      category: "Food"
    }
  }
  
  puts "\n💰 Creando gasto de prueba..."
  make_request('POST', "#{API_BASE}/expenses", data, headers)
end

# Función principal
def main
  puts "🚀 Iniciando pruebas de la API House Finances"
  puts "Base URL: #{BASE_URL}"
  puts "API Base: #{API_BASE}"
  puts "=" * 50
  
  # Probar endpoint de salud
  puts "\n🏥 Probando endpoint de salud..."
  make_request('GET', "#{BASE_URL}/up")
  
  # Login
  puts "\n🔐 Intentando login..."
  token = login('test@example.com', 'password123')
  
  if token
    # Probar endpoints protegidos
    test_protected_endpoints(token)
    
    # Crear gasto de prueba
    create_test_expense(token)
    
    puts "\n✅ Todas las pruebas completadas"
  else
    puts "\n❌ No se pudo obtener token. Verificar credenciales y servidor."
  end
end

# Ejecutar si se llama directamente
if __FILE__ == $0
  main
end
