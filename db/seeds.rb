# db/seeds.rb
# Idempotente: usa find_or_create_by para não duplicar ao rodar várias vezes.

puts "Criando usuários de seed..."

# Admin — criado em todos os ambientes
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

puts "  Admin → admin@payloop.dev / senha@123"

# Tudo abaixo é exclusivo para desenvolvimento e staging
if Rails.env.production?
  puts ""
  puts "Ambiente de produção: seeds de demonstração ignorados."
  return
end

# Customer genérico
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

# ---------------------------------------------------------------------------
puts ""
puts "Criando WebhookToken de demonstração..."

webhook_token = WebhookToken.find_or_create_by!(webhook: "gateway_callbacks") do |t|
  t.token = "demo_webhook_token_payloop_2026"
end
puts "  Token → #{webhook_token.http_authentication_token}"

# ---------------------------------------------------------------------------
puts ""
puts "Criando clientes de demonstração..."

basico_mensal = Plan.find_by!(name: "Básico Mensal")

# Cliente 1 — Chaves: assinatura ativa, 1 pagamento succeeded
chaves = User.find_or_create_by!(email: "chaves@payloop.dev") do |u|
  u.password              = "senha@123"
  u.password_confirmation = "senha@123"
  u.role                  = :customer
  u.confirmed_at          = Time.current
end
chaves.profile || Profile.find_or_create_by!(document: "00000000010") do |p|
  p.user      = chaves
  p.full_name = "Chaves"
  p.phone     = "47900000010"
end
sub_chaves = Subscription.find_or_initialize_by(user: chaves, plan: basico_mensal)
unless sub_chaves.persisted?
  sub_chaves.assign_attributes(
    status:         :active,
    payment_method: "credit_card",
    joined_at:      Date.current,
    next_due_date:  1.month.from_now.to_date
  )
  sub_chaves.save!
  Payment.create!(
    subscription:     sub_chaves,
    amount_cents:     basico_mensal.price_cents,
    currency:         "BRL",
    payment_method:   "credit_card",
    status:           :succeeded,
    attempt_number:   1,
    transaction_id:   SecureRandom.uuid,
    gateway_response: { method: "credit_card", simulated: true }.to_json
  )
end
puts "  Chaves    → chaves@payloop.dev    (ativa / succeeded)"

# Cliente 2 — Kiko: assinatura cancelada, 1 pagamento succeeded
kiko = User.find_or_create_by!(email: "kiko@payloop.dev") do |u|
  u.password              = "senha@123"
  u.password_confirmation = "senha@123"
  u.role                  = :customer
  u.confirmed_at          = Time.current
end
kiko.profile || Profile.find_or_create_by!(document: "00000000011") do |p|
  p.user      = kiko
  p.full_name = "Kiko"
  p.phone     = "47900000011"
end
sub_kiko = Subscription.find_or_initialize_by(user: kiko, plan: basico_mensal)
unless sub_kiko.persisted?
  sub_kiko.assign_attributes(
    status:         :canceled,
    payment_method: "credit_card",
    joined_at:      1.month.ago.to_date,
    next_due_date:  Date.current,
    canceled_at:    Date.current
  )
  sub_kiko.save!
  Payment.create!(
    subscription:     sub_kiko,
    amount_cents:     basico_mensal.price_cents,
    currency:         "BRL",
    payment_method:   "credit_card",
    status:           :succeeded,
    attempt_number:   1,
    transaction_id:   SecureRandom.uuid,
    gateway_response: { method: "credit_card", simulated: true }.to_json
  )
end
puts "  Kiko      → kiko@payloop.dev      (cancelada / succeeded)"

# Cliente 3 — Chiquinha: assinatura pending_payment, 1 pagamento pending
# Cenário de demo: webhook com "succeeded" deve ativar a assinatura
chiquinha = User.find_or_create_by!(email: "chiquinha@payloop.dev") do |u|
  u.password              = "senha@123"
  u.password_confirmation = "senha@123"
  u.role                  = :customer
  u.confirmed_at          = Time.current
end
chiquinha.profile || Profile.find_or_create_by!(document: "00000000012") do |p|
  p.user      = chiquinha
  p.full_name = "Chiquinha"
  p.phone     = "47900000012"
end
sub_chiquinha = Subscription.find_or_initialize_by(user: chiquinha, plan: basico_mensal)
unless sub_chiquinha.persisted?
  sub_chiquinha.assign_attributes(
    status:         :pending_payment,
    payment_method: "boleto",
    joined_at:      Date.current,
    next_due_date:  Date.current
  )
  sub_chiquinha.save!
  Payment.create!(
    subscription:   sub_chiquinha,
    amount_cents:   basico_mensal.price_cents,
    currency:       "BRL",
    payment_method: "boleto",
    status:         :pending,
    attempt_number: 1,
    transaction_id: "chiquinha-demo-transaction-001"
  )
end
puts "  Chiquinha → chiquinha@payloop.dev (pending_payment / pending)"
puts "             transaction_id: chiquinha-demo-transaction-001"

# Cliente 4 — Nhonho: assinatura error_payment, 1 pagamento failed
nhonho = User.find_or_create_by!(email: "nhonho@payloop.dev") do |u|
  u.password              = "senha@123"
  u.password_confirmation = "senha@123"
  u.role                  = :customer
  u.confirmed_at          = Time.current
end
nhonho.profile || Profile.find_or_create_by!(document: "00000000013") do |p|
  p.user      = nhonho
  p.full_name = "Nhonho"
  p.phone     = "47900000013"
end
sub_nhonho = Subscription.find_or_initialize_by(user: nhonho, plan: basico_mensal)
unless sub_nhonho.persisted?
  sub_nhonho.assign_attributes(
    status:         :error_payment,
    payment_method: "credit_card",
    joined_at:      Date.current,
    next_due_date:  Date.current
  )
  sub_nhonho.save!
  Payment.create!(
    subscription:     sub_nhonho,
    amount_cents:     basico_mensal.price_cents,
    currency:         "BRL",
    payment_method:   "credit_card",
    status:           :failed,
    attempt_number:   1,
    transaction_id:   SecureRandom.uuid,
    gateway_response: { method: "credit_card", simulated: true, error: "insufficient_funds" }.to_json
  )
end
puts "  Nhonho    → nhonho@payloop.dev    (error_payment / failed)"

puts ""
puts "Criando configurações de métodos de pagamento..."

%w[credit_card boleto bank_deposit].each do |key|
  PaymentMethodConfig.find_or_create_by!(key: key) do |config|
    config.enabled = true
  end
  puts "  #{key} → ativo"
end

puts ""
puts "Demo webhook:"
puts "  curl -X POST http://localhost:3000/webhooks/gateway_callbacks \\"
puts "    -H \"X-Signature: #{webhook_token.http_authentication_token}\" \\"
puts "    -H \"Content-Type: application/json\" \\"
puts "    -d '{\"transaction_id\": \"chiquinha-demo-transaction-001\", \"status\": \"succeeded\"}'"
