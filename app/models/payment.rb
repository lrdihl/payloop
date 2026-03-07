class Payment < ApplicationRecord
  # 3. Associations
  belongs_to :subscription

  # 4. Field settings
  composed_of :amount,
    class_name:  "Shared::Values::Money",
    mapping:     [ %w[amount_cents cents], %w[currency currency] ],
    constructor: ->(cents, currency) { Shared::Values::Money.new(cents: cents, currency: currency) }

  enum :status, {
    pending:   "pending",
    succeeded: "succeeded",
    failed:    "failed"
  }, default: :pending

  # 5. Validations
  validates :amount_cents,   presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :attempt_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency,       presence: true
  validates :payment_method, presence: true
  validates :status,         presence: true
end
