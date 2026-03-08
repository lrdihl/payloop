# Garante que todos os métodos de pagamento sejam carregados antes de cada request,
# populando o Registry tanto no boot quanto após reloads em development.
Rails.application.config.to_prepare do
  Shared::PaymentMethods::CreditCard
  Shared::PaymentMethods::Boleto
  Shared::PaymentMethods::BankDeposit
end
