class PaymentMethod::CreditCard < PaymentMethod
  Shared::PaymentMethods::Registry.register(:credit_card, self)

  def human_name
    "Cartão de Crédito"
  end

  def simulate(money:)
    Rails.logger.info "[Cartão de Crédito] Simulando cobrança de #{money}"
    :success
  end

  def process(money:)
    simulate(money:)
  end
end
