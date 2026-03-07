# spec/domains/subscriptions/operations/fail_subscription_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Operations::FailSubscription do
  subject(:operation) { described_class.new }

  # ─── Fluxo feliz ────────────────────────────────────────────────────────────

  describe "com transição válida (pending_payment -> error_payment)" do
    let(:subscription) { create(:subscription) }

    it "retorna Success com a subscription atualizada" do
      result = operation.call(subscription)
      expect(result).to be_success
      expect(result.value!).to be_a(Subscription)
    end

    it "atualiza o status para error_payment" do
      operation.call(subscription)
      expect(subscription.reload.status).to eq("error_payment")
    end
  end

  # ─── Transição inválida ──────────────────────────────────────────────────────

  describe "com transição inválida" do
    it "retorna Failure quando já está error_payment" do
      sub = create(:subscription, :error_payment)
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
