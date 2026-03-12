# spec/domains/billing/operations/process_payment_concurrency_spec.rb
require "rails_helper"

RSpec.describe Billing::Operations::ProcessPayment, "controle de concorrência" do
  subject(:operation) { described_class.new }

  let(:subscription) { create(:subscription, payment_method: "credit_card") }

  describe "build_payment com lock pessimista" do
    it "executa dentro de um lock na subscription" do
      # Verifica que a subscription recebe with_lock
      allow(subscription).to receive(:with_lock).and_yield
      allow(subscription).to receive(:reload).and_return(subscription)

      operation.call(subscription: subscription)

      expect(subscription).to have_received(:with_lock)
    end
  end
end
