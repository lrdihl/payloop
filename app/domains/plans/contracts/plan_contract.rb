module Plans
  module Contracts
    class PlanContract < Dry::Validation::Contract
      VALID_CURRENCIES     = %w[BRL USD].freeze
      VALID_INTERVAL_TYPES = %w[month year].freeze
      VALID_DURATION_TYPES = %w[month year].freeze

      params do
        required(:name).filled(:string)
        optional(:description).maybe(:string)
        required(:price_cents).filled(:integer)
        required(:currency).filled(:string)
        required(:interval_count).filled(:integer)
        required(:interval_type).filled(:string)
        required(:active).filled(:bool)
        optional(:duration_count).maybe(:integer)
        optional(:duration_type).maybe(:string)
        optional(:renewable).maybe(:bool)
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

      rule(:duration_count) do
        next unless value
        key.failure("deve ser maior que zero") if value <= 0
      end

      rule(:duration_type) do
        next unless value
        key.failure("deve ser month ou year") unless VALID_DURATION_TYPES.include?(value)
      end

      rule(:duration_count, :duration_type) do
        dc = values[:duration_count]
        dt = values[:duration_type]
        if dc.present? && dt.blank?
          key(:duration_type).failure("é obrigatório quando duration_count está preenchido")
        elsif dt.present? && dc.blank?
          key(:duration_count).failure("é obrigatório quando duration_type está preenchido")
        end
      end
    end
  end
end
