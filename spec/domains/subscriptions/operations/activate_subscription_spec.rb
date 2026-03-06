# spec/domains/subscriptions/operations/activate_subscription_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Operations::ActivateSubscription do
  subject(:operation) { described_class.new }

  let(:plan) { create(:plan, interval_count: 1, interval_type: "month") }
  let(:subscription) { create(:subscription, plan:, next_due_date: Date.current) }

  # ─── Fluxo feliz ────────────────────────────────────────────────────────────

  describe "com transição válida (pending_payment -> active)" do
    it "retorna Success com a subscription atualizada" do
      result = operation.call(subscription)
      expect(result).to be_success
      expect(result.value!).to be_a(Subscription)
    end

    it "atualiza o status para active" do
      operation.call(subscription)
      expect(subscription.reload.status).to eq("active")
    end

    it "recalcula next_due_date como old_next_due_date + interval do plano" do
      old_next_due_date = subscription.next_due_date
      operation.call(subscription)
      expect(subscription.reload.next_due_date).to eq(old_next_due_date >> 1)
    end
  end

  # ─── Transição inválida ──────────────────────────────────────────────────────

  describe "com transição inválida" do
    it "retorna Failure quando já está active" do
      active_sub = create(:subscription, :active, plan:)
      result = operation.call(active_sub)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:invalid_transition)
    end

    it "retorna Failure quando está canceled" do
      canceled_sub = create(:subscription, :canceled, plan:)
      result = operation.call(canceled_sub)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:invalid_transition)
    end

    it "retorna Failure quando está closed" do
      closed_sub = create(:subscription, :closed, plan:)
      result = operation.call(closed_sub)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:invalid_transition)
    end

    it "não altera o status em caso de transição inválida" do
      canceled_sub = create(:subscription, :canceled, plan:)
      operation.call(canceled_sub)
      expect(canceled_sub.reload.status).to eq("canceled")
    end
  end
end
