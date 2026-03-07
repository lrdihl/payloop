# spec/domains/billing/contracts/gateway_callback_contract_spec.rb
require "rails_helper"

RSpec.describe Billing::Contracts::GatewayCallbackContract do
  subject(:contract) { described_class.new }

  let(:valid_params) do
    {
      transaction_id:   SecureRandom.uuid,
      status:           "succeeded",
      gateway_response: { "code" => "00", "message" => "ok" }
    }
  end

  # ─── transaction_id ──────────────────────────────────────────────────────────

  describe "transaction_id" do
    it "é válido quando preenchido" do
      expect(contract.call(valid_params)).to be_success
    end

    it "falha quando ausente" do
      result = contract.call(valid_params.except(:transaction_id))
      expect(result).to be_failure
      expect(result.errors[:transaction_id]).not_to be_empty
    end

    it "falha quando vazio" do
      result = contract.call(valid_params.merge(transaction_id: ""))
      expect(result).to be_failure
      expect(result.errors[:transaction_id]).not_to be_empty
    end
  end

  # ─── status ──────────────────────────────────────────────────────────────────

  describe "status" do
    it "é válido com 'succeeded'" do
      expect(contract.call(valid_params.merge(status: "succeeded"))).to be_success
    end

    it "é válido com 'failed'" do
      expect(contract.call(valid_params.merge(status: "failed"))).to be_success
    end

    it "falha quando ausente" do
      result = contract.call(valid_params.except(:status))
      expect(result).to be_failure
      expect(result.errors[:status]).not_to be_empty
    end

    it "falha com status inválido" do
      result = contract.call(valid_params.merge(status: "pending"))
      expect(result).to be_failure
      expect(result.errors[:status]).not_to be_empty
    end

    it "falha com status desconhecido" do
      result = contract.call(valid_params.merge(status: "unknown"))
      expect(result).to be_failure
      expect(result.errors[:status]).not_to be_empty
    end
  end

  # ─── gateway_response ────────────────────────────────────────────────────────

  describe "gateway_response" do
    it "é válido quando ausente (opcional)" do
      expect(contract.call(valid_params.except(:gateway_response))).to be_success
    end

    it "é válido quando nil" do
      expect(contract.call(valid_params.merge(gateway_response: nil))).to be_success
    end

    it "é válido quando presente como hash" do
      expect(contract.call(valid_params.merge(gateway_response: { "foo" => "bar" }))).to be_success
    end

    it "é válido quando presente como string" do
      expect(contract.call(valid_params.merge(gateway_response: '{"foo":"bar"}'))).to be_success
    end
  end
end
