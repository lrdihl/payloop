module Subscriptions
  module Operations
    class UpdatePaymentMethod
      include Dry::Transaction

      step :validate
      step :persist

      private

      def validate(input)
        result = Contracts::UpdatePaymentMethodContract.new.call(input.slice(:payment_method))
        if result.success?
          Dry::Monads::Success(input.merge(result.to_h))
        else
          Dry::Monads::Failure({ type: :validation, errors: result.errors.to_h })
        end
      end

      def persist(input)
        subscription = input.fetch(:subscription)
        if subscription.update(payment_method: input[:payment_method])
          Dry::Monads::Success(subscription)
        else
          Dry::Monads::Failure({ type: :persistence, errors: subscription.errors })
        end
      end
    end
  end
end
