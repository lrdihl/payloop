module Subscriptions
  module Operations
    class ActivateSubscription
      include Dry::Transaction

      step :check_transition
      step :update_status

      private

      def check_transition(subscription)
        if subscription.valid_transition?("active")
          Dry::Monads::Success(subscription)
        else
          Dry::Monads::Failure({ type: :invalid_transition, errors: { status: [ "transição inválida: #{subscription.status} -> active" ] } })
        end
      end

      def update_status(subscription)
        new_next_due_date = subscription.plan.interval.advance_from(subscription.next_due_date)

        if subscription.update(status: :active, next_due_date: new_next_due_date)
          Dry::Monads::Success(subscription)
        else
          Dry::Monads::Failure({ type: :persistence, errors: subscription.errors })
        end
      rescue ActiveRecord::StaleObjectError
        Dry::Monads::Failure({ type: :stale, errors: { base: ["registro alterado por outro processo"] } })
      end
    end
  end
end
