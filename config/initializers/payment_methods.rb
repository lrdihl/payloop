# Garante que todos os métodos de pagamento sejam carregados antes de cada request,
# populando o Registry tanto no boot quanto após reloads em development.
Rails.application.config.to_prepare do
  Shared::PaymentMethods::CreditCard
  Shared::PaymentMethods::Boleto
  Shared::PaymentMethods::BankDeposit
  Shared::PaymentMethods::Manual

  # Recupera estado persistido após reinicialização do servidor.
  # O comportamento realtime é garantido pela operation TogglePaymentMethod
  # que atualiza DB e Registry atomicamente durante cada toggle.
  # O rescue cobre ambientes sem banco (ex: assets:precompile no build Docker).
  begin
    if ActiveRecord::Base.connection.table_exists?(:payment_method_configs)
      PaymentMethodConfig.find_each do |config|
        if config.enabled?
          Shared::PaymentMethods::Registry.enable(config.key)
        else
          Shared::PaymentMethods::Registry.disable(config.key)
        end
      end
    end
  rescue ActiveRecord::NoDatabaseError, ArgumentError
    # Banco não disponível em tempo de build — ignorar.
  end
end
