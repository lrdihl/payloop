module Billing
  module Operations
    class ProcessPayment
      include Dry::Transaction

      step :build_payment
      step :call_gateway

      private

      def build_payment(input)
        subscription = input.fetch(:subscription)

        subscription.with_lock do
          plan = subscription.plan

          subscription.payments.pending.update_all(status: "voided")

          next_attempt = subscription.payments.maximum(:attempt_number).to_i + 1

          payment = Payment.new(
            subscription:   subscription,
            amount:         plan.price,
            payment_method: subscription.payment_method,
            status:         :pending,
            attempt_number: next_attempt
          )

          if payment.save
            return Dry::Monads::Success(input.merge(payment: payment))
          else
            return Dry::Monads::Failure({ type: :persistence, errors: payment.errors })
          end
        end
      end

      def call_gateway(input)
        payment = input.fetch(:payment)
        pm      = Shared::PaymentMethods::Registry.find(payment.payment_method.to_sym).new

        result = pm.process(payment:)

        if result.success?
          payment.save!
          Dry::Monads::Success(payment)
        else
          payment.update(status: :failed)
          Dry::Monads::Failure({ type: :gateway, errors: result.failure })
        end
      end
    end
  end
end
