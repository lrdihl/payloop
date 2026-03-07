module Shared
  module PaymentMethods
    class CreditCard < Base
      Registry.register(:credit_card, self)

      def human_name
        "Cartão de Crédito"
      end

      def process(money:)
        Rails.logger.info "[Cartão de Crédito] Simulando cobrança de #{money}"
        :success
      end
    end
  end
end
