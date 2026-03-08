module Billing
  module Jobs
    class BillingJob < ApplicationJob
      MAX_RETRIES = ENV.fetch("BILLING_MAX_RETRIES", "5").to_i

      retry_on Billing::GatewayError, attempts: MAX_RETRIES, wait: :polynomially_longer

      after_discard do |job, error|
        job.send(:on_discard, error)
      end

      def perform(subscription_id)
        subscription = Subscription.find(subscription_id)
        return unless subscription.pending_payment?

        result = Billing::Operations::ProcessPayment.new.call(
          subscription: subscription
        )

        raise Billing::GatewayError, result.failure[:errors].to_s if result.failure?
      end

      private

      def on_discard(_error)
        subscription = Subscription.find(arguments.first)
        Subscriptions::Operations::FailSubscription.new.call(subscription)
      end
    end
  end
end
