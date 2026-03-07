module ApplicationHelper
  STATUS_BADGE = {
    "pending_payment" => "bg-warning text-dark",
    "active"          => "bg-success",
    "error_payment"   => "bg-danger",
    "canceled"        => "bg-secondary",
    "closed"          => "bg-dark"
  }.freeze

  PAYMENT_STATUS_BADGE = {
    "pending"   => "bg-warning text-dark",
    "succeeded" => "bg-success",
    "failed"    => "bg-danger"
  }.freeze

  def status_badge_class(status)
    STATUS_BADGE.fetch(status.to_s, "bg-secondary")
  end

  def payment_status_badge_class(status)
    PAYMENT_STATUS_BADGE.fetch(status.to_s, "bg-secondary")
  end
end
