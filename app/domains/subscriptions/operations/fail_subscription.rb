module Subscriptions
  module Operations
    class FailSubscription
      include Dry::Transaction

      step :check_transition
      step :update_status

      private

      def check_transition(subscription)
        if subscription.valid_transition?("error_payment")
          Dry::Monads::Success(subscription)
        else
          Dry::Monads::Failure({ type: :invalid_transition, errors: { status: [ "transição inválida: #{subscription.status} -> error_payment" ] } })
        end
      end

      def update_status(subscription)
        if subscription.update(status: :error_payment)
          Dry::Monads::Success(subscription)
        else
          Dry::Monads::Failure({ type: :persistence, errors: subscription.errors })
        end
      end
    end
  end
end
