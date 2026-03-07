# Garante que todos os métodos de pagamento sejam carregados na inicialização,
# populando o Registry antes de qualquer request.
Rails.application.config.after_initialize do
  Shared::PaymentMethods::CreditCard
  Shared::PaymentMethods::Boleto
  Shared::PaymentMethods::BankDeposit
end
