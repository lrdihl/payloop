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

admin.profile || Profile.find_or_create_by!(document: "00000000001") do |p|
  p.user      = admin
  p.full_name = "Administrador"
  p.phone     = "47900000001"
end

# Customer
customer = User.find_or_create_by!(email: "customer@payloop.dev") do |u|
  u.password              = "senha@123"
  u.password_confirmation = "senha@123"
  u.role                  = :customer
  u.confirmed_at          = Time.current
end

customer.profile || Profile.find_or_create_by!(document: "00000000002") do |p|
  p.user      = customer
  p.full_name = "Cliente Teste"
  p.phone     = "47900000002"
end

puts ""
puts "  Admin    → admin@payloop.dev    / senha@123"
puts "  Customer → customer@payloop.dev / senha@123"

puts ""
puts "Criando planos de seed..."

[
  { name: "Básico Mensal",        price_cents: 4990,  interval_count: 1, interval_type: "month" },
  { name: "Intermediário Mensal", price_cents: 6990,  interval_count: 1, interval_type: "month" },
  { name: "Top Mensal",           price_cents: 9990,  interval_count: 1, interval_type: "month" },
  { name: "Básico Anual",         price_cents: 49900, interval_count: 1, interval_type: "year"  },
  { name: "Intermediário Anual",  price_cents: 69900, interval_count: 1, interval_type: "year"  },
  { name: "Top Anual",            price_cents: 99900, interval_count: 1, interval_type: "year"  }
].each do |attrs|
  Plan.find_or_create_by!(name: attrs[:name]) do |p|
    p.price_cents    = attrs[:price_cents]
    p.currency       = "BRL"
    p.interval_count = attrs[:interval_count]
    p.interval_type  = attrs[:interval_type]
    p.active         = true
  end
  puts "  #{attrs[:name]}"
end
