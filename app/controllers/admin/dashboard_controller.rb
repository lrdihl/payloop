module Admin
  class DashboardController < BaseController
    layout "admin"

    def index
      skip_authorization

      @billing_months        = build_billing_chart
      @active_count          = Subscription.active.count
      @pending_subscriptions = Subscription.pending_payment
                                           .includes(:user, :plan, :payments)
                                           .order(created_at: :desc)
    end

    private

    def build_billing_chart
      4.downto(0).map do |i|
        date  = i.months.ago
        total = Payment.succeeded
                       .where(created_at: date.beginning_of_month..date.end_of_month)
                       .sum(:amount_cents)
        { label: I18n.l(date, format: :month_year), amount_cents: total }
      end
    end
  end
end
