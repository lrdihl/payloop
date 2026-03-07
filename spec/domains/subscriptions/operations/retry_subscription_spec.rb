# spec/domains/subscriptions/operations/retry_subscription_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Operations::RetrySubscription do
  subject(:operation) { described_class.new }

  # ─── Fluxo feliz ────────────────────────────────────────────────────────────

  describe "com transição válida (error_payment -> pending_payment)" do
    let(:subscription) { create(:subscription, :error_payment) }

    it "retorna Success com a subscription atualizada" do
      result = operation.call(subscription)
      expect(result).to be_success
      expect(result.value!).to be_a(Subscription)
    end

    it "atualiza o status para pending_payment" do
      operation.call(subscription)
      expect(subscription.reload.status).to eq("pending_payment")
    end
  end

  # ─── Enqueue do BillingJob ──────────────────────────────────────────────────

  describe "enfileiramento do BillingJob" do
    include ActiveJob::TestHelper

    let(:subscription) { create(:subscription, :error_payment) }

    it "enfileira BillingJob após mover para pending_payment" do
      expect {
        operation.call(subscription)
      }.to have_enqueued_job(Billing::Jobs::BillingJob).with(subscription.id)
    end

    it "não enfileira BillingJob quando a transição é inválida" do
      sub = create(:subscription, :active)
      expect {
        operation.call(sub)
      }.not_to have_enqueued_job(Billing::Jobs::BillingJob)
    end
  end

  # ─── Transição inválida ──────────────────────────────────────────────────────

  describe "com transição inválida" do
    it "retorna Failure quando está pending_payment" do
      sub = create(:subscription)
      result = operation.call(sub)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:invalid_transition)
    end

    it "retorna Failure quando está active" do
      sub = create(:subscription, :active)
      result = operation.call(sub)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:invalid_transition)
    end

    it "retorna Failure quando está canceled" do
      sub = create(:subscription, :canceled)
      result = operation.call(sub)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:invalid_transition)
    end

    it "não altera o status em caso de transição inválida" do
      sub = create(:subscription, :active)
      operation.call(sub)
      expect(sub.reload.status).to eq("active")
    end
  end
end
