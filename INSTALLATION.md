# Instalación y Configuración - House Finances API

## Requisitos Previos

- Ruby 3.4.5 o superior
- PostgreSQL 9.3 o superior
- Node.js (para importmap)
- Bundler

## Pasos de Instalación

### 1. Clonar el repositorio

```bash
git clone <repository-url>
cd house-finances-api
```

### 2. Instalar dependencias de Ruby

```bash
bundle install
```

### 3. Configurar base de datos

```bash
# Crear la base de datos
rails db:create

# Ejecutar migraciones
rails db:migrate

# Poblar con datos de prueba (opcional)
rails db:seed
```

### 4. Configurar credenciales (opcional)

```bash
# Editar credenciales si es necesario
rails credentials:edit
```

### 5. Iniciar el servidor

```bash
rails server
```

La API estará disponible en: `http://localhost:3000`

## Estructura de la API

### Endpoints principales

- **Base URL**: `/api/v1`
- **Autenticación**: `/users/sign_in` (POST)
- **Gastos**: `/api/v1/expenses`
- **Perfil**: `/api/v1/profile`

### Rutas disponibles

```
GET    /api/v1/expenses          # Listar gastos
POST   /api/v1/expenses          # Crear gasto
GET    /api/v1/expenses/:id      # Ver gasto
PUT    /api/v1/expenses/:id      # Actualizar gasto
DELETE /api/v1/expenses/:id      # Eliminar gasto
GET    /api/v1/expenses/summary  # Resumen de gastos
GET    /api/v1/expenses/categories # Categorías disponibles
GET    /api/v1/profile           # Perfil del usuario
```

## Configuración de Desarrollo

### Variables de entorno

```bash
# Crear archivo .env (opcional)
cp .env.example .env

# Editar variables según necesidad
RAILS_ENV=development
DATABASE_URL=postgresql://localhost/house_finances_api_development
```

### Base de datos de desarrollo

```bash
# Verificar conexión
rails db:version

# Resetear base de datos (cuidado: borra todos los datos)
rails db:reset

# Ver estado de migraciones
rails db:migrate:status
```

## Testing

### Ejecutar todas las pruebas

```bash
rails test
```

### Ejecutar pruebas específicas

```bash
# Solo controladores
rails test test/controllers/

# Solo modelos
rails test test/models/

# Archivo específico
rails test test/controllers/api/v1/expenses_controller_test.rb
```

### Verificar código con RuboCop

```bash
bundle exec rubocop
```

## Autenticación

### 1. Crear usuario de prueba

```bash
rails console
```

```ruby
# En la consola de Rails
user = User.create!(
  email: 'test@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)
puts "Usuario creado: #{user.email}"
```

### 2. Obtener token JWT

```bash
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"password123"}}'
```

### 3. Usar token en peticiones

```bash
curl -X GET http://localhost:3000/api/v1/expenses \
  -H "Authorization: Bearer <token_jwt_aqui>"
```

## Estructura de Archivos

```
app/
├── controllers/
│   ├── api/
│   │   └── v1/
│   │       ├── base_controller.rb      # Controlador base API
│   │       ├── expenses_controller.rb  # Controlador de gastos
│   │       └── users_controller.rb     # Controlador de usuarios
│   └── application_controller.rb       # Controlador principal
├── models/
│   ├── expense.rb                      # Modelo de gastos
│   ├── user.rb                         # Modelo de usuarios
│   └── jwt_denylist.rb                # Modelo de tokens revocados
└── views/                              # Vistas (no se usan en API)

config/
├── routes.rb                           # Configuración de rutas
├── database.yml                        # Configuración de BD
├── initializers/
│   ├── api_config.rb                   # Configuración de la API
│   ├── devise_jwt.rb                   # Configuración JWT
│   └── cors.rb                         # Configuración CORS

db/
├── migrate/                            # Migraciones de BD
└── seeds.rb                            # Datos de prueba

test/
├── controllers/api/v1/                 # Pruebas de controladores
├── models/                             # Pruebas de modelos
└── fixtures/                           # Datos de prueba
```

## Solución de Problemas

### Error de conexión a base de datos

```bash
# Verificar que PostgreSQL esté corriendo
sudo service postgresql status

# Verificar configuración
rails db:configuration
```

### Error de migraciones

```bash
# Ver estado de migraciones
rails db:migrate:status

# Forzar migración
rails db:migrate:up VERSION=20250813000000
```

### Error de autenticación

```bash
# Verificar configuración de Devise
rails routes | grep devise

# Verificar secret key
rails credentials:show
```

### Error de CORS

```bash
# Verificar configuración
cat config/initializers/cors.rb

# Reiniciar servidor después de cambios
rails server
```

## Despliegue

### Producción

```bash
# Configurar variables de entorno
export RAILS_ENV=production
export SECRET_KEY_BASE=<generated_key>

# Precompilar assets
rails assets:precompile

# Ejecutar migraciones
rails db:migrate RAILS_ENV=production

# Iniciar servidor
rails server -e production
```

### Docker

```bash
# Construir imagen
docker build -t house-finances-api .

# Ejecutar contenedor
docker run -p 3000:3000 house-finances-api
```

## Recursos Adicionales

- [Documentación de la API](API_README.md)
- [Rails Guides](https://guides.rubyonrails.org/)
- [Devise Documentation](https://github.com/heartcombo/devise)
- [JWT Documentation](https://github.com/waiting-for-dev/devise-jwt)

## Soporte

Para reportar bugs o solicitar características:

1. Crear un issue en el repositorio
2. Incluir logs de error
3. Describir pasos para reproducir el problema
4. Especificar versión de Ruby y Rails
