# spec/domains/billing/operations/handle_gateway_callback_spec.rb
require "rails_helper"

RSpec.describe Billing::Operations::HandleGatewayCallback do
  subject(:operation) { described_class.new }

  let(:subscription) { create(:subscription) }
  let(:transaction_id) { SecureRandom.uuid }
  let(:payment) { create(:payment, subscription: subscription, transaction_id: transaction_id) }

  let(:valid_params) do
    {
      transaction_id:   transaction_id,
      status:           "succeeded",
      gateway_response: { "code" => "00", "message" => "ok" }.to_json
    }
  end

  before { payment } # persiste o payment antes dos exemplos

  # ─── Fluxo succeeded ─────────────────────────────────────────────────────────

  describe "fluxo succeeded" do
    it "retorna Success" do
      expect(operation.call(valid_params)).to be_success
    end

    it "atualiza o payment para succeeded" do
      operation.call(valid_params)
      expect(payment.reload.status).to eq("succeeded")
    end

    it "salva o gateway_response no payment" do
      operation.call(valid_params)
      expect(payment.reload.gateway_response).to be_present
    end

    it "move a subscription para active" do
      operation.call(valid_params)
      expect(subscription.reload.status).to eq("active")
    end

    it "retorna o payment no value!" do
      result = operation.call(valid_params)
      expect(result.value!).to be_a(Payment)
    end
  end

  # ─── Fluxo failed ────────────────────────────────────────────────────────────

  describe "fluxo failed" do
    let(:params) { valid_params.merge(status: "failed") }

    it "retorna Success" do
      expect(operation.call(params)).to be_success
    end

    it "atualiza o payment para failed" do
      operation.call(params)
      expect(payment.reload.status).to eq("failed")
    end

    it "move a subscription para error_payment" do
      operation.call(params)
      expect(subscription.reload.status).to eq("error_payment")
    end
  end

  # ─── transaction_id não encontrado ───────────────────────────────────────────

  describe "quando transaction_id não é encontrado" do
    let(:params) { valid_params.merge(transaction_id: "inexistente-uuid") }

    it "retorna Failure com tipo :not_found" do
      result = operation.call(params)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:not_found)
    end

    it "não altera nenhuma subscription" do
      operation.call(params)
      expect(subscription.reload.status).to eq("pending_payment")
    end
  end

  # ─── Validação do contract ────────────────────────────────────────────────────

  describe "quando o payload é inválido" do
    it "retorna Failure com tipo :validation quando transaction_id está ausente" do
      result = operation.call(valid_params.except(:transaction_id))
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
    end

    it "retorna Failure com tipo :validation quando status é inválido" do
      result = operation.call(valid_params.merge(status: "pending"))
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
    end
  end

  # ─── Idempotência ────────────────────────────────────────────────────────────

  describe "idempotência — payment já processado" do
    before { payment.update!(status: :succeeded) }

    it "retorna Success sem reprocessar" do
      result = operation.call(valid_params)
      expect(result).to be_success
    end

    it "não altera o status do payment" do
      operation.call(valid_params)
      expect(payment.reload.status).to eq("succeeded")
    end

    it "não altera o status da subscription" do
      original_status = subscription.status
      operation.call(valid_params)
      expect(subscription.reload.status).to eq(original_status)
    end
  end
end
