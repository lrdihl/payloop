module Shared
  module PaymentMethods
    class BankDeposit < Base
      Registry.register(:bank_deposit, self)

      def process(payment:)
        Rails.logger.info "[Depósito Bancário] Simulando cobrança de #{payment.amount}"
        payment.transaction_id   = SecureRandom.uuid
        payment.gateway_response = { method: "bank_deposit", simulated: true, timestamp: Time.current.iso8601 }.to_json
        Dry::Monads::Success(payment)
      end
    end
  end
end
