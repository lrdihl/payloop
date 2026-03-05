module Plans
  module Operations
    class DiscardPlan
      include Dry::Transaction

      step :discard

      private

      def discard(input)
        plan = input[:plan]

        if plan.discard
          Dry::Monads::Success(plan)
        else
          Dry::Monads::Failure({ type: :persistence, errors: plan.errors })
        end
      end
    end
  end
end
