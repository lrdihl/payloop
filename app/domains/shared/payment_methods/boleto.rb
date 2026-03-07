module Shared
  module PaymentMethods
    class Boleto < Base
      Registry.register(:boleto, self)

      def human_name
        "Boleto Bancário"
      end

      def process(payment:)
        Rails.logger.info "[Boleto] Simulando cobrança de #{payment.amount}"
        payment.transaction_id   = SecureRandom.uuid
        payment.gateway_response = { method: "boleto", simulated: true, timestamp: Time.current.iso8601 }.to_json
        Dry::Monads::Success(payment)
      end
    end
  end
end
