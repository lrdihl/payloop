module Shared
  module PaymentMethods
    class BankDeposit < Base
      Registry.register(:bank_deposit, self)

      def human_name
        "Depósito Bancário"
      end

      def process(money:)
        Rails.logger.info "[Depósito Bancário] Simulando cobrança de #{money}"
        :success
      end
    end
  end
end
