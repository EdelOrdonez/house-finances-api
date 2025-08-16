# House Finances API

API RESTful para gestión de gastos domésticos con autenticación JWT.

## Características

- ✅ Autenticación JWT con Devise
- ✅ CRUD completo para gastos
- ✅ Filtros y paginación
- ✅ Validaciones robustas
- ✅ Manejo de errores estandarizado
- ✅ Respuestas JSON consistentes
- ✅ Rutas anidadas en `/api/v1`

## Instalación

1. **Instalar dependencias**

   ```bash
   bundle install
   ```

2. **Configurar base de datos**

   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

3. **Iniciar servidor**
   ```bash
   rails server
   ```

## Autenticación

La API utiliza JWT (JSON Web Tokens) para autenticación. Incluye el token en el header de todas las peticiones:

```
Authorization: Bearer <your_jwt_token>
```

### Obtener token de autenticación

```bash
# Login
POST /users/sign_in
{
  "user": {
    "email": "test@example.com",
    "password": "password123"
  }
}
```

## Endpoints

### Base URL

```
http://localhost:3000/api/v1
```

### Gastos (Expenses)

#### Listar gastos

```http
GET /expenses
GET /expenses?category=Food
GET /expenses?start_date=2024-01-01&end_date=2024-01-31
GET /expenses?page=1&per_page=10
```

**Headers requeridos:**

```
Authorization: Bearer <jwt_token>
```

**Respuesta:**

```json
{
  "status": "success",
  "data": {
    "expenses": [...],
    "meta": {
      "total_count": 25,
      "current_page": 1,
      "per_page": 20
    }
  }
}
```

#### Obtener gasto específico

```http
GET /expenses/:id
```

#### Crear gasto

```http
POST /expenses
```

**Body:**

```json
{
  "expense": {
    "description": "Comida en restaurante",
    "amount": 45.5,
    "date": "2024-01-15",
    "category": "Food"
  }
}
```

#### Actualizar gasto

```http
PUT /expenses/:id
PATCH /expenses/:id
```

#### Eliminar gasto

```http
DELETE /expenses/:id
```

#### Resumen de gastos

```http
GET /expenses/summary
```

**Respuesta:**

```json
{
  "status": "success",
  "data": {
    "total_expenses": 1250.75,
    "total_count": 25,
    "by_category": {
      "Food": 450.25,
      "Transport": 200.5
    },
    "this_month": 325.75
  }
}
```

#### Categorías disponibles

```http
GET /expenses/categories
```

### Usuario

#### Perfil del usuario

```http
GET /profile
```

## Estructura de Respuestas

### Respuesta Exitosa

```json
{
  "status": "success",
  "data": {...},
  "message": "Optional message"
}
```

### Respuesta de Error

```json
{
  "status": "error",
  "message": "Error description",
  "errors": ["Detailed error 1", "Detailed error 2"]
}
```

## Códigos de Estado HTTP

- `200` - OK
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `422` - Unprocessable Entity
- `500` - Internal Server Error

## Validaciones

### Expense

- `description`: Requerido, 3-255 caracteres
- `amount`: Requerido, mayor que 0
- `date`: Requerido, formato YYYY-MM-DD
- `category`: Requerido, máximo 100 caracteres

### User

- `email`: Requerido, formato válido, único
- `password`: Requerido, mínimo 6 caracteres

## Filtros Disponibles

- **Por categoría**: `?category=Food`
- **Por rango de fechas**: `?start_date=2024-01-01&end_date=2024-01-31`
- **Paginación**: `?page=1&per_page=20`

## Ejemplos de Uso

### cURL

```bash
# Login
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"password123"}}'

# Crear gasto
curl -X POST http://localhost:3000/api/v1/expenses \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{"expense":{"description":"Gasolina","amount":50.00,"date":"2024-01-15","category":"Transport"}}'

# Listar gastos
curl -X GET http://localhost:3000/api/v1/expenses \
  -H "Authorization: Bearer <jwt_token>"
```

### JavaScript (Fetch)

```javascript
// Login
const loginResponse = await fetch("/users/sign_in", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    user: { email: "test@example.com", password: "password123" },
  }),
});

const { token } = await loginResponse.json();

// Crear gasto
const expenseResponse = await fetch("/api/v1/expenses", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    expense: {
      description: "Comida",
      amount: 25.5,
      date: "2024-01-15",
      category: "Food",
    },
  }),
});
```

## Desarrollo

### Ejecutar tests

```bash
rails test
```

### Verificar código con RuboCop

```bash
bundle exec rubocop
```

### Generar documentación de rutas

```bash
rails routes | grep api
```

## Dependencias

- Rails 8.0
- Devise (autenticación)
- Devise-JWT (tokens JWT)
- Kaminari (paginación)
- PostgreSQL (base de datos)

## Licencia

MIT License
