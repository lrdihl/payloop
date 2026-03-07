module Subscriptions
  module Contracts
    class UpdatePaymentMethodContract < Dry::Validation::Contract
      params do
        required(:payment_method).filled(:string)
      end

      rule(:payment_method) do
        active_keys = Shared::PaymentMethods::Registry.active_methods.keys.map(&:to_s)
        key.failure("não é um método de pagamento ativo") unless active_keys.include?(value)
      end
    end
  end
end
