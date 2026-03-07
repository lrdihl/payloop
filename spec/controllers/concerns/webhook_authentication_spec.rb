# spec/controllers/concerns/webhook_authentication_spec.rb
require "rails_helper"

RSpec.describe WebhookAuthentication, type: :controller do
  controller(ActionController::Base) do
    include WebhookAuthentication

    authentication_through :header_token, "X-Signature"

    before_action :authenticate

    def index
      render json: { ok: true }
    end
  end

  let!(:webhook_token) do
    create(:webhook_token, webhook: "anonymous", token: "valid-token-abc")
  end

  describe "autenticação via header_token" do
    context "com token válido" do
      it "permite o acesso (200)" do
        request.headers["X-Signature"] = "valid-token-abc"
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context "com token inválido" do
      it "retorna 401" do
        request.headers["X-Signature"] = "token-errado"
        get :index
        expect(response).to have_http_status(:unauthorized)
      end

      it "retorna mensagem de erro" do
        request.headers["X-Signature"] = "token-errado"
        get :index
        body = JSON.parse(response.body)
        expect(body["messages"]).to include("Invalid Authentication Token")
      end
    end

    context "sem token" do
      it "retorna 401" do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "autenticação via http_authentication_token" do
    controller(ActionController::Base) do
      include WebhookAuthentication

      authentication_through :http_authentication_token

      before_action :authenticate

      def index
        render json: { ok: true }
      end
    end

    context "com token Bearer válido no X-Signature" do
      it "permite o acesso (200)" do
        request.headers["X-Signature"] = "Bearer valid-token-abc"
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context "com token Token válido no X-Signature" do
      it "permite o acesso (200)" do
        request.headers["X-Signature"] = "Token valid-token-abc"
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context "com token inválido" do
      it "retorna 401" do
        request.headers["X-Signature"] = "Bearer errado"
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe ".authentication_through" do
    it "armazena a configuração de autenticação na classe" do
      config = controller.class.authentication_config
      expect(config[:method]).to eq(:header_token)
      expect(config[:param]).to eq("X-Signature")
    end
  end
end
