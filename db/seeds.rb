# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Creating users..."

# Crear usuario de prueba (o usar el existente)
user = User.find_or_create_by(email: 'test@example.com') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
end

puts "User: #{user.email}"

puts "Creating sample expenses..."

# Limpiar gastos existentes del usuario
user.expenses.destroy_all

# Crear gastos de ejemplo
categories = ['Food', 'Transport', 'Entertainment', 'Shopping', 'Bills', 'Health']

20.times do |i|
  Expense.create!(
    user: user,
    description: "Sample expense #{i + 1}",
    amount: rand(10.0..500.0).round(2),
    date: rand(30.days.ago.to_date..Date.current),
    category: categories.sample
  )
end

puts "Created #{Expense.count} expenses for user #{user.email}"

puts "Seeding completed!"
