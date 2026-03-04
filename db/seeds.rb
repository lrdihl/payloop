# db/seeds.rb
# Idempotente: usa find_or_create_by para não duplicar ao rodar várias vezes.

puts "Criando usuários de seed..."

# Admin
admin = User.find_or_create_by!(email: "admin@payloop.dev") do |u|
  u.password              = "senha@123"
  u.password_confirmation = "senha@123"
  u.role                  = :admin
  u.confirmed_at          = Time.current
end

admin.profile || admin.create_profile!(
  full_name: "Administrador",
  document:  "00000000001",
  phone:     "47900000001"
)

# Consumer
consumer = User.find_or_create_by!(email: "consumer@payloop.dev") do |u|
  u.password              = "senha@123"
  u.password_confirmation = "senha@123"
  u.role                  = :consumer
  u.confirmed_at          = Time.current
end

consumer.profile || consumer.create_profile!(
  full_name: "Consumidor Teste",
  document:  "00000000002",
  phone:     "47900000002"
)

puts ""
puts "  Admin    → admin@payloop.dev    / senha@123"
puts "  Consumer → consumer@payloop.dev / senha@123"
