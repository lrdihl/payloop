module Billing
  module Jobs
    class CloseSubscriptionsJob < ApplicationJob
      def perform
        Subscription.active.where(closed_at: Date.current).find_each do |subscription|
          Subscriptions::Operations::CloseSubscription.new.call(subscription)
        end
      end
    end
  end
end
