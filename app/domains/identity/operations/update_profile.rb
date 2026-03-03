# app/domains/identity/operations/update_profile.rb
#
# Caso de uso: consumidor atualiza seus próprios dados de perfil.
# A autorização (quem pode chamar isso) é responsabilidade da Policy — não desta operation.
#
module Identity
  module Operations
    class UpdateProfile
      include Dry::Transaction

      step :validate
      step :persist

      private

      def validate(input)
        result = Contracts::UpdateProfileContract.new.call(input[:attributes])

        if result.success?
          Dry::Monads::Success(input.merge(validated: result.to_h))
        else
          Dry::Monads::Failure({ type: :validation, errors: result.errors.to_h })
        end
      end

      def persist(input)
        profile = input[:profile]

        if profile.update(input[:validated])
          Dry::Monads::Success(profile)
        else
          Dry::Monads::Failure({ type: :persistence, errors: profile.errors.to_h })
        end
      end
    end
  end
end
