# app/domains/identity/contracts/update_profile_contract.rb
module Identity
  module Contracts
    class UpdateProfileContract < Dry::Validation::Contract
      params do
        required(:full_name).filled(:string)
        required(:document).filled(:string)
        optional(:phone).maybe(:string)
      end

      rule(:full_name) do
        key.failure("deve ter no mínimo 3 caracteres") if value.strip.length < 3
      end

      rule(:document) do
        cleaned = value.gsub(/\D/, "")
        unless cleaned.length == 11 || cleaned.length == 14
          key.failure("deve ser um CPF (11 dígitos) ou CNPJ (14 dígitos)")
        end
      end
    end
  end
end
