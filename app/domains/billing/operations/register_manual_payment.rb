module Billing
  module Operations
    class RegisterManualPayment
      include Dry::Transaction

      step :create_payment
      step :activate_subscription

      private

      def create_payment(subscription)
        next_attempt = subscription.payments.maximum(:attempt_number).to_i + 1

        payment = Payment.new(
          subscription:   subscription,
          amount:         subscription.plan.price,
          payment_method: "manual",
          status:         :succeeded,
          attempt_number: next_attempt,
          transaction_id: SecureRandom.uuid,
          gateway_response: { method: "manual", recorded_by: "admin" }.to_json
        )

        if payment.save
          Dry::Monads::Success(subscription)
        else
          Dry::Monads::Failure({ type: :persistence, errors: payment.errors })
        end
      end

      def activate_subscription(subscription)
        Subscriptions::Operations::ActivateSubscription.new.call(subscription)
      end
    end
  end
end
