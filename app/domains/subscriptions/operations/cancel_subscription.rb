module Subscriptions
  module Operations
    class CancelSubscription
      include Dry::Transaction

      step :check_transition
      step :update_status

      private

      def check_transition(subscription)
        if subscription.valid_transition?("canceled")
          Dry::Monads::Success(subscription)
        else
          Dry::Monads::Failure({ type: :invalid_transition, errors: { status: [ "transição inválida: #{subscription.status} -> canceled" ] } })
        end
      end

      def update_status(subscription)
        if subscription.update(status: :canceled, canceled_at: Date.current)
          Dry::Monads::Success(subscription)
        else
          Dry::Monads::Failure({ type: :persistence, errors: subscription.errors })
        end
      end
    end
  end
end
