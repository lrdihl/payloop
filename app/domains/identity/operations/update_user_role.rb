# app/domains/identity/operations/update_user_role.rb
#
# Caso de uso exclusivo de admin: promover/rebaixar usuário.
# Separado do UpdateProfile porque tem regras e autorizações distintas.
#
module Identity
  module Operations
    class UpdateUserRole
      include Dry::Monads[:result]

      VALID_ROLES = User.roles.keys.freeze

      def call(user:, role:)
        return Failure({ type: :validation, errors: { role: ["papel inválido"] } }) \
          unless VALID_ROLES.include?(role.to_s)

        if user.update(role: role)
          Success(user)
        else
          Failure({ type: :persistence, errors: user.errors.to_h })
        end
      end
    end
  end
end
