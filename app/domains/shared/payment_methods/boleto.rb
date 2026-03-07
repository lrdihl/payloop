module Shared
  module PaymentMethods
    class Boleto < Base
      Registry.register(:boleto, self)

      def human_name
        "Boleto Bancário"
      end

      def process(money:)
        Rails.logger.info "[Boleto] Simulando cobrança de #{money}"
        :success
      end
    end
  end
end
