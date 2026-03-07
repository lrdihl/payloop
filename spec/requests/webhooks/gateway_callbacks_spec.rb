# spec/requests/webhooks/gateway_callbacks_spec.rb
require "rails_helper"

RSpec.describe "Webhooks::GatewayCallbacks", type: :request do
  let(:webhook_token) { create(:webhook_token, webhook: "gateway_callbacks") }
  let(:token_header)  { { "X-Signature" => "Token #{webhook_token.token}" } }

  let(:subscription)    { create(:subscription) }
  let(:transaction_id)  { SecureRandom.uuid }
  let(:payment)         { create(:payment, subscription: subscription, transaction_id: transaction_id) }

  let(:valid_payload) do
    {
      transaction_id:   transaction_id,
      status:           "succeeded",
      gateway_response: { "code" => "00" }
    }
  end

  before { payment } # persiste payment e subscription

  # ─── Autenticação ────────────────────────────────────────────────────────────

  describe "sem token" do
    it "retorna 401" do
      post webhooks_gateway_callbacks_path, params: valid_payload, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "com token inválido" do
    it "retorna 401" do
      post webhooks_gateway_callbacks_path,
           params:  valid_payload,
           headers: { "X-Signature" => "Token token-invalido" },
           as:      :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # ─── Payload inválido ────────────────────────────────────────────────────────

  describe "com payload inválido" do
    it "retorna 422 quando transaction_id está ausente" do
      post webhooks_gateway_callbacks_path,
           params:  valid_payload.except(:transaction_id),
           headers: token_header,
           as:      :json
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "retorna 422 quando status é inválido" do
      post webhooks_gateway_callbacks_path,
           params:  valid_payload.merge(status: "pending"),
           headers: token_header,
           as:      :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  # ─── transaction_id não encontrado ───────────────────────────────────────────

  describe "quando transaction_id não existe" do
    it "retorna 404" do
      post webhooks_gateway_callbacks_path,
           params:  valid_payload.merge(transaction_id: "inexistente"),
           headers: token_header,
           as:      :json
      expect(response).to have_http_status(:not_found)
    end
  end

  # ─── Fluxo succeeded ─────────────────────────────────────────────────────────

  describe "POST /webhooks/gateway_callbacks — succeeded" do
    before do
      post webhooks_gateway_callbacks_path,
           params:  valid_payload,
           headers: token_header,
           as:      :json
    end

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "move a subscription para active" do
      expect(subscription.reload.status).to eq("active")
    end

    it "atualiza o payment para succeeded" do
      expect(payment.reload.status).to eq("succeeded")
    end
  end

  # ─── Fluxo failed ────────────────────────────────────────────────────────────

  describe "POST /webhooks/gateway_callbacks — failed" do
    before do
      post webhooks_gateway_callbacks_path,
           params:  valid_payload.merge(status: "failed"),
           headers: token_header,
           as:      :json
    end

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "move a subscription para error_payment" do
      expect(subscription.reload.status).to eq("error_payment")
    end

    it "atualiza o payment para failed" do
      expect(payment.reload.status).to eq("failed")
    end
  end
end
