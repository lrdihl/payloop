module Identity
  module Operations
    class RegisterUser
      include Dry::Transaction
      include Dry::Monads[:result]

      step :validate

      private

      # Step 1: Valida a estrutura e semântica da entrada
      def validate(input)
        result = Contracts::RegisterContract.new.call(input)

        if result.success?
          Success(result.to_h)
        else
          Failure({ type: :validation, errors: result.errors.to_h })
        end
      end
    end
  end
end
