# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Creating strategies..."

# Crear estrategias de división de gastos
proportional_strategy = Strategy.find_or_create_by(name: 'Proportional') do |s|
  s.description = 'Divide gastos proporcionalmente según el ingreso de cada usuario'
end

equal_strategy = Strategy.find_or_create_by(name: 'Equal') do |s|
  s.description = 'Divide gastos equitativamente entre todos los usuarios'
end

puts "Strategies: #{Strategy.pluck(:name).join(', ')}"

puts "Creating users..."

# Crear usuarios de prueba con diferentes ingresos
users_data = [
  { name: 'Ana García', email: 'ana@example.com', password: 'password123', income: 45000.00 },
  { name: 'Carlos López', email: 'carlos@example.com', password: 'password123', income: 38000.00 },
  { name: 'María Rodríguez', email: 'maria@example.com', password: 'password123', income: 52000.00 },
  { name: 'Luis Martínez', email: 'luis@example.com', password: 'password123', income: 42000.00 }
]

users = []
users_data.each do |user_data|
  user = User.find_or_create_by(email: user_data[:email]) do |u|
    u.name = user_data[:name]
    u.password = user_data[:password]
    u.income = user_data[:income]
  end
  users << user
end

puts "Users created: #{users.map(&:name).join(', ')}"

puts "Creating financial groups..."

# Crear grupo financiero "Roomies CDMX"
roomies_group = FinancialGroup.find_or_create_by(name: 'Roomies CDMX') do |g|
  g.description = 'Gastos compartidos entre roomies en CDMX'
  g.strategy = proportional_strategy
end

# Agregar usuarios al grupo
users.each do |user|
  roomies_group.add_user(user) unless roomies_group.users.include?(user)
end

puts "Financial group created: #{roomies_group.name} with #{roomies_group.users.count} users"

puts "Creating sample expenses..."

# Limpiar gastos existentes
Expense.destroy_all
Contribution.destroy_all

# Crear gastos personales
users.each do |user|
  rand(3..6).times do |i|
    Expense.create!(
      user: user,
      description: "Gasto personal #{i + 1} de #{user.name}",
      amount: rand(100.0..800.0).round(2),
      date: rand(30.days.ago.to_date..Date.current),
      category: ['Food', 'Transport', 'Entertainment', 'Shopping', 'Bills', 'Health'].sample
    )
  end
end

# Crear gastos compartidos en el grupo
shared_expenses_data = [
  { description: 'Renta del departamento', amount: 15000.00, category: 'Bills', date: Date.current.beginning_of_month },
  { description: 'Servicios (luz, agua, gas)', amount: 2500.00, category: 'Bills', date: Date.current.beginning_of_month },
  { description: 'Internet y cable', amount: 1200.00, category: 'Bills', date: Date.current.beginning_of_month },
  { description: 'Limpieza del departamento', amount: 800.00, category: 'Bills', date: Date.current.beginning_of_month },
  { description: 'Artículos de cocina compartidos', amount: 1500.00, category: 'Shopping', date: 5.days.ago.to_date },
  { description: 'Cena grupal', amount: 1200.00, category: 'Food', date: 3.days.ago.to_date },
  { description: 'Transporte compartido', amount: 600.00, category: 'Transport', date: 2.days.ago.to_date }
]

shared_expenses_data.each do |expense_data|
  Expense.create!(
    user: users.sample,
    financial_group: roomies_group,
    description: expense_data[:description],
    amount: expense_data[:amount],
    date: expense_data[:date],
    category: expense_data[:category]
  )
end

puts "Created #{Expense.personal.count} personal expenses"
puts "Created #{Expense.shared.count} shared expenses"
puts "Created #{Contribution.count} contributions"

# Mostrar resumen de contribuciones
puts "\nContributions summary:"
roomies_group.expenses.shared.each do |expense|
  puts "  #{expense.description} ($#{expense.amount}):"
  expense.contributions.includes(:user).each do |contribution|
    puts "    #{contribution.user.name}: #{contribution.formatted_percentage} = $#{contribution.formatted_amount_due}"
  end
end

puts "\nUser balances in #{roomies_group.name}:"
users.each do |user|
  balance = roomies_group.user_balance(user)
  status = balance >= 0 ? "✅" : "❌"
  puts "  #{status} #{user.name}: $#{balance} (Ingreso: $#{user.income})"
end

puts "\nSeeding completed!"
