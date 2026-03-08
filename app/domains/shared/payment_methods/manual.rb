module Shared
  module PaymentMethods
    class Manual < Base
      Registry.register(:manual, self)

      def self.selectable?
        false
      end

      def human_name
        "Pagamento Manual"
      end

      def process(payment:)
        payment.transaction_id   = SecureRandom.uuid
        payment.gateway_response = { method: "manual", recorded_by: "admin" }.to_json
        Dry::Monads::Success(payment)
      end
    end
  end
end
