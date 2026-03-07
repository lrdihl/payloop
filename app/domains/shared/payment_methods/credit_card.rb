module Shared
  module PaymentMethods
    class CreditCard < Base
      Registry.register(:credit_card, self)

      def human_name
        "Cartão de Crédito"
      end

      def process(payment:)
        Rails.logger.info "[Cartão de Crédito] Simulando cobrança de #{payment.amount}"
        payment.transaction_id   = SecureRandom.uuid
        payment.gateway_response = { method: "credit_card", simulated: true, timestamp: Time.current.iso8601 }.to_json
        Dry::Monads::Success(payment)
      end
    end
  end
end
