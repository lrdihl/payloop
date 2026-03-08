class PaymentMethodConfig < ApplicationRecord
  SELECTABLE_KEYS = %w[credit_card boleto bank_deposit].freeze

  validates :key,     presence: true,
                      uniqueness: true,
                      inclusion: { in: SELECTABLE_KEYS }
  validates :enabled, inclusion: { in: [true, false] }
end
