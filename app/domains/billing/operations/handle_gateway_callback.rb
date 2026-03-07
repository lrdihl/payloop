module Billing
  module Operations
    class HandleGatewayCallback
      include Dry::Transaction

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

        payment  = input[:payment]
        response = input[:gateway_response]
        response = response.to_json unless response.is_a?(String) || response.nil?

        if payment.update(status: input[:status], gateway_response: response)
          Dry::Monads::Success(input.merge(payment: payment))
        else
          Dry::Monads::Failure({ type: :persistence, errors: payment.errors })
        end
      end

      def propagate_to_subscription(input)
        return Dry::Monads::Success(input[:payment]) if input[:already_processed]

        payment      = input[:payment]
        subscription = payment.subscription

        operation = case input[:status].to_s
                    when "succeeded" then Subscriptions::Operations::ActivateSubscription.new
                    when "failed"    then Subscriptions::Operations::FailSubscription.new
                    end

        operation.call(subscription)
        Dry::Monads::Success(payment)
      end
    end
  end
end
