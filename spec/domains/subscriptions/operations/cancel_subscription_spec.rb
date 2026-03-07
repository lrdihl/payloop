# spec/domains/subscriptions/operations/cancel_subscription_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Operations::CancelSubscription do
  subject(:operation) { described_class.new }

  # ─── Fluxo feliz — de active ─────────────────────────────────────────────────

  describe "com transição válida (active -> canceled)" do
    let(:subscription) { create(:subscription, :active) }

    it "retorna Success com a subscription atualizada" do
      result = operation.call(subscription)
      expect(result).to be_success
      expect(result.value!).to be_a(Subscription)
    end

    it "atualiza o status para canceled" do
      operation.call(subscription)
      expect(subscription.reload.status).to eq("canceled")
    end

    it "preenche canceled_at com a data atual" do
      operation.call(subscription)
      expect(subscription.reload.canceled_at).to eq(Date.current)
    end
  end

  # ─── Fluxo feliz — de error_payment ─────────────────────────────────────────

  describe "com transição válida (error_payment -> canceled)" do
    let(:subscription) { create(:subscription, :error_payment) }

    it "retorna Success" do
      result = operation.call(subscription)
      expect(result).to be_success
    end

    it "atualiza o status para canceled" do
      operation.call(subscription)
      expect(subscription.reload.status).to eq("canceled")
    end

    it "preenche canceled_at com a data atual" do
      operation.call(subscription)
      expect(subscription.reload.canceled_at).to eq(Date.current)
    end
  end

  # ─── Transição inválida ──────────────────────────────────────────────────────

  describe "com transição inválida" do
    it "retorna Failure quando está closed" do
      sub = create(:subscription, :closed)
      result = operation.call(sub)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:invalid_transition)
    end

    it "retorna Failure quando já está canceled" do
      sub = create(:subscription, :canceled)
      result = operation.call(sub)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:invalid_transition)
    end

    it "não altera o status em caso de transição inválida" do
      sub = create(:subscription, :closed)
      operation.call(sub)
      expect(sub.reload.status).to eq("closed")
    end
  end
end
