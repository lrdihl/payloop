module Plans
  module Operations
    class UpdatePlan
      include Dry::Transaction

      step :validate
      step :persist

      private

      def validate(input)
        result = Contracts::PlanContract.new.call(input.except(:plan))

        if result.success?
          Dry::Monads::Success(input.merge(attributes: result.to_h))
        else
          Dry::Monads::Failure({ type: :validation, errors: result.errors.to_h })
        end
      end

      def persist(input)
        plan = input[:plan]

        if plan.update(input[:attributes])
          Dry::Monads::Success(plan)
        else
          Dry::Monads::Failure({ type: :persistence, errors: plan.errors })
        end
      end
    end
  end
end
