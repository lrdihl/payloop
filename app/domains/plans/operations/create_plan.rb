module Plans
  module Operations
    class CreatePlan
      include Dry::Transaction

      step :validate
      step :persist

      private

      def validate(input)
        result = Contracts::PlanContract.new.call(input)

        if result.success?
          Dry::Monads::Success(result.to_h)
        else
          Dry::Monads::Failure({ type: :validation, errors: result.errors.to_h })
        end
      end

      def persist(input)
        plan = Plan.new(input)

        if plan.save
          Dry::Monads::Success(plan)
        else
          Dry::Monads::Failure({ type: :persistence, errors: plan.errors })
        end
      end
    end
  end
end
