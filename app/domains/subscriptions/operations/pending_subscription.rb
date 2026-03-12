module Subscriptions
  module Operations
    class PendingSubscription
      include Dry::Transaction
      include Shared::Concerns::StaleObjectHandler

      step :check_transition
      step :update_status

      private

      def check_transition(subscription)
        if subscription.valid_transition?("pending_payment")
          Dry::Monads::Success(subscription)
        else
          Dry::Monads::Failure({ type: :invalid_transition, errors: { status: [ "transição inválida: #{subscription.status} -> pending_payment" ] } })
        end
      end

      def update_status(subscription)
        guard_stale do
          if subscription.update(status: :pending_payment)
            Dry::Monads::Success(subscription)
          else
            Dry::Monads::Failure({ type: :persistence, errors: subscription.errors })
          end
        end
      end
    end
  end
end
