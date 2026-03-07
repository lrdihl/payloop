# spec/requests/admin/subscriptions_spec.rb
require "rails_helper"

RSpec.describe "Admin::Subscriptions", type: :request do
  let(:admin)    { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }
  let(:plan)     { create(:plan) }
  let(:subscription) { create(:subscription, user: customer, plan:) }

  before { sign_in admin }

  # ─── GET /admin/subscriptions ────────────────────────────────────────────────

  describe "GET /admin/subscriptions" do
    before { subscription; get admin_subscriptions_path }

    it "retorna 200 para admin" do
      expect(response).to have_http_status(:ok)
    end

    it "usa o layout admin" do
      expect(response.body).to include("app-wrapper")
    end

    context "quando customer acessa" do
      before { sign_in customer; get admin_subscriptions_path }

      it "redireciona com alerta" do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  # ─── GET /admin/subscriptions/:id ────────────────────────────────────────────

  describe "GET /admin/subscriptions/:id" do
    before { get admin_subscription_path(subscription) }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end
  end

  # ─── GET /admin/subscriptions/new ────────────────────────────────────────────

  describe "GET /admin/subscriptions/new" do
    before { get new_admin_subscription_path }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end
  end

  # ─── POST /admin/subscriptions ───────────────────────────────────────────────

  describe "POST /admin/subscriptions" do
    let(:valid_params) do
      {
        subscription: {
          user_id:   customer.id,
          plan_id:   plan.id,
          joined_at: Date.current.to_s
        }
      }
    end

    it "cria assinatura e redireciona" do
      post admin_subscriptions_path, params: valid_params
      expect(response).to have_http_status(:redirect)
    end

    it "aumenta o count de subscriptions" do
      expect {
        post admin_subscriptions_path, params: valid_params
      }.to change(Subscription, :count).by(1)
    end

    context "com dados inválidos" do
      it "retorna 422" do
        post admin_subscriptions_path, params: { subscription: { user_id: "", plan_id: "", joined_at: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "quando customer tenta criar" do
      before { sign_in customer }

      it "redireciona com alerta" do
        post admin_subscriptions_path, params: valid_params
        expect(response).to have_http_status(:redirect)
      end

      it "não cria assinatura" do
        expect {
          post admin_subscriptions_path, params: valid_params
        }.not_to change(Subscription, :count)
      end
    end
  end

  # ─── Ações de transição ───────────────────────────────────────────────────────

  describe "PATCH /admin/subscriptions/:id/activate" do
    it "redireciona após ativar" do
      patch activate_admin_subscription_path(subscription)
      expect(response).to have_http_status(:redirect)
    end

    it "atualiza status para active" do
      patch activate_admin_subscription_path(subscription)
      expect(subscription.reload.status).to eq("active")
    end

    context "com transição inválida" do
      let(:subscription) { create(:subscription, :active, user: customer, plan:) }

      it "redireciona com alert" do
        patch activate_admin_subscription_path(subscription)
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(response.body).to include("inválida")
      end
    end
  end

  describe "PATCH /admin/subscriptions/:id/fail" do
    it "redireciona após marcar erro" do
      patch fail_admin_subscription_path(subscription)
      expect(response).to have_http_status(:redirect)
    end

    it "atualiza status para error_payment" do
      patch fail_admin_subscription_path(subscription)
      expect(subscription.reload.status).to eq("error_payment")
    end
  end

  describe "PATCH /admin/subscriptions/:id/retry" do
    let(:subscription) { create(:subscription, :error_payment, user: customer, plan:) }

    it "redireciona após retry" do
      patch retry_admin_subscription_path(subscription)
      expect(response).to have_http_status(:redirect)
    end

    it "atualiza status para pending_payment" do
      patch retry_admin_subscription_path(subscription)
      expect(subscription.reload.status).to eq("pending_payment")
    end
  end

  describe "PATCH /admin/subscriptions/:id/cancel" do
    let(:subscription) { create(:subscription, :active, user: customer, plan:) }

    it "redireciona após cancelar" do
      patch cancel_admin_subscription_path(subscription)
      expect(response).to have_http_status(:redirect)
    end

    it "atualiza status para canceled" do
      patch cancel_admin_subscription_path(subscription)
      expect(subscription.reload.status).to eq("canceled")
    end
  end

  describe "PATCH /admin/subscriptions/:id/close" do
    let(:subscription) { create(:subscription, :active, user: customer, plan:) }

    it "redireciona após fechar" do
      patch close_admin_subscription_path(subscription)
      expect(response).to have_http_status(:redirect)
    end

    it "atualiza status para closed" do
      patch close_admin_subscription_path(subscription)
      expect(subscription.reload.status).to eq("closed")
    end
  end
end
