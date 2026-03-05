module Plans
  module Contracts
    class PlanContract < Dry::Validation::Contract
      VALID_CURRENCIES    = %w[BRL USD].freeze
      VALID_INTERVAL_TYPES = %w[month year].freeze

      params do
        required(:name).filled(:string)
        optional(:description).maybe(:string)
        required(:price_cents).filled(:integer)
        required(:currency).filled(:string)
        required(:interval_count).filled(:integer)
        required(:interval_type).filled(:string)
        required(:active).filled(:bool)
      end

      rule(:price_cents) do
        key.failure("deve ser maior que zero") if value <= 0
      end

      rule(:currency) do
        key.failure("deve ser BRL ou USD") unless VALID_CURRENCIES.include?(value)
      end

      rule(:interval_count) do
        key.failure("deve ser maior que zero") if value <= 0
      end

      rule(:interval_type) do
        key.failure("deve ser month ou year") unless VALID_INTERVAL_TYPES.include?(value)
      end
    end
  end
end
