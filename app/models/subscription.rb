class Subscription < ApplicationRecord
  VALID_TRANSITIONS = {
    "pending_payment" => %w[active error_payment],
    "error_payment"   => %w[pending_payment canceled],
    "active"          => %w[canceled closed pending_payment],
    "canceled"        => [],
    "closed"          => []
  }.freeze

  belongs_to :user
  belongs_to :plan

  enum :status, {
    pending_payment: "pending_payment",
    active:          "active",
    error_payment:   "error_payment",
    canceled:        "canceled",
    closed:          "closed"
  }, default: :pending_payment

  validates :joined_at,       presence: true
  validates :next_due_date,   presence: true
  validates :payment_method,  presence: true,
                              inclusion: { in: ->(_) { Shared::PaymentMethods::Registry.all.keys.map(&:to_s) } }

  scope :current, -> { where(status: %w[active pending_payment]) }

  def valid_transition?(new_status)
    VALID_TRANSITIONS[status].include?(new_status.to_s)
  end

  def residual_value
    return nil if closed_at.nil?

    days_remaining = (closed_at - Date.current).to_i
    return 0 if days_remaining <= 0

    days_period = (closed_at - joined_at).to_i
    (plan.price_cents * days_remaining.to_f / days_period).round
  end
end
