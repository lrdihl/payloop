module Subscriptions
  module Operations
    class CreateSubscription
      include Dry::Transaction

      step :validate
      step :check_no_active
      step :calculate_dates
      step :persist

      private

      def validate(input)
        result = Contracts::CreateSubscriptionContract.new.call(input)

        if result.success?
          Dry::Monads::Success(result.to_h)
        else
          Dry::Monads::Failure({ type: :validation, errors: result.errors.to_h })
        end
      end

      def check_no_active(input)
        conflict = Subscription.current.exists?(user_id: input[:user_id])

        if conflict
          Dry::Monads::Failure({ type: :conflict, errors: { base: [ "já existe uma assinatura ativa ou pendente" ] } })
        else
          Dry::Monads::Success(input)
        end
      end

      def calculate_dates(input)
        plan = Plan.find(input[:plan_id])

        Dry::Monads::Success(input.merge(
          plan:      plan,
          closed_at: plan.duration.advance_from(input[:joined_at])
        ))
      end

      def persist(input)
        subscription = Subscription.new(
          user_id:        input[:user_id],
          plan:           input[:plan],
          status:         :pending_payment,
          payment_method: input[:payment_method],
          joined_at:      input[:joined_at],
          next_due_date:  input[:joined_at],
          closed_at:      input[:closed_at]
        )

        if subscription.save
          Billing::Jobs::BillingJob.perform_later(subscription.id)
          Dry::Monads::Success(subscription)
        else
          Dry::Monads::Failure({ type: :persistence, errors: subscription.errors })
        end
      end
    end
  end
end
