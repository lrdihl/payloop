module ApplicationHelper
  STATUS_BADGE = {
    "pending_payment" => "bg-warning text-dark",
    "active"          => "bg-success",
    "error_payment"   => "bg-danger",
    "canceled"        => "bg-secondary",
    "closed"          => "bg-dark"
  }.freeze

  def status_badge_class(status)
    STATUS_BADGE.fetch(status.to_s, "bg-secondary")
  end
end
