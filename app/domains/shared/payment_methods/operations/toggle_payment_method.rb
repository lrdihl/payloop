module Shared
  module PaymentMethods
    module Operations
      class TogglePaymentMethod
        include Dry::Transaction

        step :validate
        step :persist
        step :sync_registry

        private

        def validate(input)
          result = Contracts::TogglePaymentMethodContract.new.call(input)
          result.success? ? Success(result.to_h) : Failure({ type: :validation, errors: result.errors.to_h })
        end

        def persist(input)
          config = PaymentMethodConfig.find_or_initialize_by(key: input[:key].to_s)
          if config.update(enabled: input[:enabled])
            Success(config)
          else
            Failure({ type: :persistence, errors: config.errors })
          end
        end

        def sync_registry(config)
          config.enabled? ? Registry.enable(config.key) : Registry.disable(config.key)
          Success(config)
        end
      end
    end
  end
end
