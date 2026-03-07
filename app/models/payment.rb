class Payment < ApplicationRecord
  belongs_to :subscription

  enum :status, {
    pending:   "pending",
    succeeded: "succeeded",
    failed:    "failed"
  }, default: :pending

  validates :amount_cents,   presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency,       presence: true
  validates :payment_method, presence: true
  validates :status,         presence: true
  validates :attempt_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
