module Identity
  module Operations
    class RegisterUser
      include Dry::Transaction

      step :validate
      step :create_user
      step :create_profile

      private

      # Step 1: Valida a estrutura e semântica da entrada
      def validate(input)
        result = Contracts::RegisterContract.new.call(input)

        if result.success?
          Dry::Monads::Success(result.to_h)
        else
          Dry::Monads::Failure({ type: :validation, errors: result.errors.to_h })
        end
      end

      # Step 2: Persiste as credenciais via ActiveRecord/Devise
      # Role é sempre :consumer no auto-registro — admin só pode ser criado por outro admin
      def create_user(input)
        user = User.new(
          email:                 input[:email],
          password:              input[:password],
          password_confirmation: input[:password_confirmation],
          role:                  :consumer
        )

        if user.save
          Dry::Monads::Success(input.merge(user: user))
        else
          Dry::Monads::Failure({ type: :persistence, errors: user.errors })
        end
      end

      # Step 3: Cria o perfil pessoal vinculado ao usuário recém-criado
      def create_profile(input)
        profile = input[:user].create_profile(
          full_name: input[:full_name],
          document:  input[:document],
          phone:     input[:phone]
        )

        if profile.persisted?
          Dry::Monads::Success(profile)
        else
          # Desfaz o usuário criado no step anterior (consistência)
          input[:user].destroy
          Dry::Monads::Failure({ type: :persistence, errors: profile.errors })
        end
      end
    end
  end
end
