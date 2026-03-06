class PaymentMethod::Boleto < PaymentMethod
  Shared::PaymentMethods::Registry.register(:boleto, self)

  def human_name
    "Boleto Bancário"
  end

  def simulate(money:)
    Rails.logger.info "[Boleto] Simulando cobrança de #{money}"
    :success
  end

  def process(money:)
    simulate(money:)
  end
end
