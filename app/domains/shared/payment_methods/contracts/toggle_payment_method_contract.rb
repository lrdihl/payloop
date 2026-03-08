module Shared
  module PaymentMethods
    module Contracts
      class TogglePaymentMethodContract < Dry::Validation::Contract
        params do
          required(:key).filled(:string)
          required(:enabled).filled(:bool)
        end

        rule(:key) do
          unless PaymentMethodConfig::SELECTABLE_KEYS.include?(value)
            key.failure("não é um método de pagamento válido")
          end
        end
      end
    end
  end
end
