# spec/domains/billing/operations/process_payment_spec.rb
require "rails_helper"

RSpec.describe Billing::Operations::ProcessPayment do
  subject(:operation) { described_class.new }

  let(:subscription) { create(:subscription, payment_method: "credit_card") }

  let(:valid_input) do
    { subscription: subscription, attempt_number: 1 }
  end

  # ─── Fluxo feliz ─────────────────────────────────────────────────────────────

  describe "com dados válidos" do
    it "retorna Success com o Payment criado" do
      result = operation.call(valid_input)
      expect(result).to be_success
      expect(result.value!).to be_a(Payment)
    end

    it "cria um registro Payment no banco" do
      expect { operation.call(valid_input) }.to change(Payment, :count).by(1)
    end

    it "cria o Payment com status pending" do
      result = operation.call(valid_input)
      expect(result.value!.status).to eq("pending")
    end

    it "copia amount_cents do plano" do
      result = operation.call(valid_input)
      expect(result.value!.amount_cents).to eq(subscription.plan.price_cents)
    end

    it "copia currency do plano" do
      result = operation.call(valid_input)
      expect(result.value!.currency).to eq(subscription.plan.currency)
    end

    it "registra o payment_method da subscription" do
      result = operation.call(valid_input)
      expect(result.value!.payment_method).to eq("credit_card")
    end

    it "registra o attempt_number" do
      result = operation.call(valid_input)
      expect(result.value!.attempt_number).to eq(1)
    end

    it "seta transaction_id no payment" do
      result = operation.call(valid_input)
      expect(result.value!.transaction_id).to be_present
    end

    it "seta gateway_response no payment" do
      result = operation.call(valid_input)
      expect(result.value!.gateway_response).to be_present
    end
  end

  # ─── Falha no gateway ────────────────────────────────────────────────────────

  describe "quando o gateway falha" do
    before do
      allow_any_instance_of(Shared::PaymentMethods::CreditCard)
        .to receive(:process)
        .and_return(Dry::Monads::Failure({ error: "gateway timeout" }))
    end

    it "retorna Failure com tipo :gateway" do
      result = operation.call(valid_input)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:gateway)
    end

    it "marca o payment como failed" do
      operation.call(valid_input)
      expect(Payment.last.status).to eq("failed")
    end

    it "ainda cria o registro Payment (para rastreabilidade)" do
      expect { operation.call(valid_input) }.to change(Payment, :count).by(1)
    end
  end

  # ─── Attempt number ──────────────────────────────────────────────────────────

  describe "com attempt_number 3" do
    it "registra attempt_number corretamente" do
      result = operation.call(valid_input.merge(attempt_number: 3))
      expect(result.value!.attempt_number).to eq(3)
    end
  end
end
