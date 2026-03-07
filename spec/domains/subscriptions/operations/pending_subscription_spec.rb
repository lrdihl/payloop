# spec/domains/subscriptions/operations/pending_subscription_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Operations::PendingSubscription do
  subject(:operation) { described_class.new }

  # ─── Fluxo feliz ────────────────────────────────────────────────────────────

  describe "com transição válida (active -> pending_payment)" do
    let(:subscription) { create(:subscription, :active) }

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

  # ─── Transição inválida ──────────────────────────────────────────────────────

  describe "com transição inválida" do
    it "retorna Failure quando já está pending_payment" do
      sub = create(:subscription)
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
      sub = create(:subscription, :canceled)
      operation.call(sub)
      expect(sub.reload.status).to eq("canceled")
    end
  end
end
