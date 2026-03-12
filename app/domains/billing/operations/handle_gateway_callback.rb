module Billing
  module Operations
    class HandleGatewayCallback
      include Dry::Transaction
      include Shared::Concerns::StaleObjectHandler

      step :validate
      step :find_payment
      step :check_idempotency
      step :update_payment
      step :propagate_to_subscription

      private

      def validate(input)
        result = Contracts::GatewayCallbackContract.new.call(input)

        if result.success?
          Dry::Monads::Success(result.to_h)
        else
          Dry::Monads::Failure({ type: :validation, errors: result.errors.to_h })
        end
      end

      def find_payment(input)
        payment = Payment.find_by(transaction_id: input[:transaction_id])

        if payment
          Dry::Monads::Success(input.merge(payment: payment))
        else
          Dry::Monads::Failure({ type: :not_found, errors: { transaction_id: [ "não encontrado" ] } })
        end
      end

      def check_idempotency(input)
        payment = input[:payment]

        if payment.pending?
          Dry::Monads::Success(input)
        else
          Dry::Monads::Success(input.merge(already_processed: true))
        end
      end

      def update_payment(input)
        return Dry::Monads::Success(input) if input[:already_processed]

        guard_stale do
          payment  = input[:payment]
          response = input[:gateway_response]
          response = response.to_json unless response.is_a?(String) || response.nil?

          if payment.update(status: input[:status], gateway_response: response)
            Dry::Monads::Success(input.merge(payment: payment))
          else
            Dry::Monads::Failure({ type: :persistence, errors: payment.errors })
          end
        end
      end

      def propagate_to_subscription(input)
        return Dry::Monads::Success(input[:payment]) if input[:already_processed]

        payment      = input[:payment]
        subscription = payment.subscription

        operation = subscription_operation(input[:status].to_s, subscription)
        result    = operation.call(subscription)

        if result.success?
          Dry::Monads::Success(payment)
        else
          Dry::Monads::Failure(result.failure)
        end
      end

      def subscription_operation(status, subscription)
        case status
        when "succeeded"
          if subscription.closed_at.present? && subscription.closed_at <= Date.current
            Subscriptions::Operations::CloseSubscription.new
          else
            Subscriptions::Operations::ActivateSubscription.new
          end
        when "failed"
          Subscriptions::Operations::FailSubscription.new
        end
      end
    end
  end
end
