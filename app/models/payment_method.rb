class PaymentMethod < ApplicationRecord
  validates :type, presence: true

  def human_name
    raise NotImplementedError, "#{self.class}#human_name não implementado"
  end

  def simulate(money:)
    raise NotImplementedError, "#{self.class}#simulate não implementado"
  end

  def process(money:)
    raise NotImplementedError, "#{self.class}#process não implementado"
  end
end
