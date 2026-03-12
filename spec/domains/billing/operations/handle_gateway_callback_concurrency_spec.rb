# spec/domains/billing/operations/handle_gateway_callback_concurrency_spec.rb
require "rails_helper"

RSpec.describe Billing::Operations::HandleGatewayCallback, "controle de concorrência" do
  subject(:operation) { described_class.new }

  let(:subscription)   { create(:subscription) }
  let(:transaction_id) { SecureRandom.uuid }
  let!(:payment)       { create(:payment, subscription: subscription, transaction_id: transaction_id) }

  let(:valid_params) do
    {
      transaction_id:   transaction_id,
      status:           "succeeded",
      gateway_response: { "code" => "00" }.to_json
    }
  end

  describe "quando ocorre StaleObjectError no update_payment" do
    it "retorna Failure com tipo :stale ao invés de estourar exceção" do
      # Simula StaleObjectError no momento do update
      allow(Payment).to receive(:find_by).and_return(payment)
      allow(payment).to receive(:update).and_raise(ActiveRecord::StaleObjectError.new("Tentativa de atualizar um objeto obsoleto: Payment."))

      result = operation.call(valid_params)

      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:stale)
    end
  end
end
