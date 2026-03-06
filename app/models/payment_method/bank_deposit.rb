class PaymentMethod::BankDeposit < PaymentMethod
  Shared::PaymentMethods::Registry.register(:bank_deposit, self)

  def human_name
    "Depósito Bancário"
  end

  def simulate(money:)
    Rails.logger.info "[Depósito Bancário] Simulando cobrança de #{money}"
    :success
  end

  def process(money:)
    simulate(money:)
  end
end
