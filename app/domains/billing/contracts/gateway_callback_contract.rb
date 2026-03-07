module Billing
  module Contracts
    class GatewayCallbackContract < Dry::Validation::Contract
      VALID_STATUSES = %w[succeeded failed].freeze

      params do
        required(:transaction_id).filled(:string)
        required(:status).filled(:string)
        optional(:gateway_response)
      end

      rule(:status) do
        key.failure("deve ser 'succeeded' ou 'failed'") unless VALID_STATUSES.include?(value)
      end
    end
  end
end
