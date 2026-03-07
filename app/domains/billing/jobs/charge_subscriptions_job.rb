module Billing
  module Jobs
    class ChargeSubscriptionsJob < ApplicationJob
      def perform
        Subscription.active.where(next_due_date: Date.current).find_each do |subscription|
          result = Subscriptions::Operations::PendingSubscription.new.call(subscription)
          BillingJob.perform_later(subscription.id) if result.success?
        end
      end
    end
  end
end
