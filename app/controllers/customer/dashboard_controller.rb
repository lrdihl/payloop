module Customer
  class DashboardController < ApplicationController
    layout "admin"

    def index
      redirect_to customer_subscriptions_path
    end
  end
end
