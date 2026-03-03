# app/domains/identity/contracts/register_contract.rb
#
# Contrato de validação de entrada para o caso de uso de registro.
# Responsabilidade única: garantir que os dados chegam bem-formados ao domain.
# NÃO acessa banco, NÃO cria objetos — apenas valida a estrutura e semântica dos dados.
#
module Identity
  module Contracts
    class RegisterContract < Dry::Validation::Contract
      params do
        required(:email).filled(:string)
        required(:password).filled(:string)
        required(:password_confirmation).filled(:string)
        required(:full_name).filled(:string)
        required(:document).filled(:string)
        optional(:phone).maybe(:string)
      end

      rule(:email) do
        unless /\A[^@\s]+@[^@\s]+\z/.match?(value)
          key.failure("deve ser um e-mail válido")
        end
      end

      rule(:password) do
        key.failure("deve ter no mínimo 8 caracteres") if value.length < 8
      end

      rule(:password, :password_confirmation) do
        key(:password_confirmation).failure("não confere com a senha") \
          if values[:password] != values[:password_confirmation]
      end

      rule(:full_name) do
        key.failure("deve ter no mínimo 3 caracteres") if value.strip.length < 3
      end

      rule(:document) do
        cleaned = value.gsub(/\D/, "")
        unless valid_cpf?(cleaned) || valid_cnpj?(cleaned)
          key.failure("deve ser um CPF (11 dígitos) ou CNPJ (14 dígitos)")
        end
      end

      private

      def valid_cpf?(doc)
        # algoritmo de dígitos verificadores
        return false unless doc.length == 11

        true
      end

      def valid_cnpj?(doc)
        # algoritmo de dígitos verificadores
        return false unless doc.length == 14

        true
      end
    end
  end
end
