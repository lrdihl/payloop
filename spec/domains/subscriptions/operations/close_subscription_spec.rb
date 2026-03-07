# spec/domains/subscriptions/operations/close_subscription_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Operations::CloseSubscription do
  subject(:operation) { described_class.new }

  # ─── Fluxo feliz ────────────────────────────────────────────────────────────

  describe "com transição válida (active -> closed)" do
    let(:subscription) { create(:subscription, :active) }

    it "retorna Success com a subscription atualizada" do
      result = operation.call(subscription)
      expect(result).to be_success
      expect(result.value!).to be_a(Subscription)
    end

    it "atualiza o status para closed" do
      operation.call(subscription)
      expect(subscription.reload.status).to eq("closed")
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

    it "retorna Failure quando está canceled" do
      sub = create(:subscription, :canceled)
      result = operation.call(sub)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:invalid_transition)
    end

    it "retorna Failure quando já está closed" do
      sub = create(:subscription, :closed)
      result = operation.call(sub)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:invalid_transition)
    end

    it "não altera o status em caso de transição inválida" do
      sub = create(:subscription)
      operation.call(sub)
      expect(sub.reload.status).to eq("pending_payment")
    end
  end
end
