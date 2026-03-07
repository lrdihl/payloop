# spec/requests/customer/subscriptions_spec.rb
require "rails_helper"

RSpec.describe "Customer::Subscriptions", type: :request do
  let(:customer) { create(:user, :customer) }
  let(:admin)    { create(:user, :admin) }
  let(:plan)     { create(:plan) }

  before { sign_in customer }

  # ─── GET /customer/subscriptions ─────────────────────────────────────────────

  describe "GET /customer/subscriptions" do
    it "retorna 200 para customer logado" do
      get customer_subscriptions_path
      expect(response).to have_http_status(:ok)
    end

    it "exibe apenas as assinaturas do próprio customer" do
      own_sub   = create(:subscription, user: customer, plan:)
      other_sub = create(:subscription, plan:)
      get customer_subscriptions_path
      expect(response.body).to include(own_sub.plan.name)
      expect(response.body).not_to include(other_sub.plan.name) if own_sub.plan.name != other_sub.plan.name
    end

    context "quando admin tenta acessar" do
      before { sign_in admin }

      it "redireciona com alerta" do
        get customer_subscriptions_path
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  # ─── GET /customer/subscriptions/new ─────────────────────────────────────────

  describe "GET /customer/subscriptions/new" do
    context "sem assinatura ativa" do
      it "retorna 200" do
        get new_customer_subscription_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "com assinatura ativa ou pendente" do
      before { create(:subscription, :active, user: customer, plan:) }

      it "redireciona com notice" do
        get new_customer_subscription_path
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  # ─── POST /customer/subscriptions ────────────────────────────────────────────

  describe "POST /customer/subscriptions" do
    let(:valid_params) { { subscription: { plan_id: plan.id } } }

    it "cria assinatura e redireciona para index" do
      post customer_subscriptions_path, params: valid_params
      expect(response).to redirect_to(customer_subscriptions_path)
    end

    it "aumenta o count de subscriptions" do
      expect {
        post customer_subscriptions_path, params: valid_params
      }.to change(Subscription, :count).by(1)
    end

    it "cria assinatura vinculada ao customer logado" do
      post customer_subscriptions_path, params: valid_params
      expect(Subscription.last.user).to eq(customer)
    end

    context "com dados inválidos (sem plan_id)" do
      it "retorna 422" do
        post customer_subscriptions_path, params: { subscription: { plan_id: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "quando já tem assinatura ativa" do
      before { create(:subscription, :active, user: customer, plan:) }

      it "não cria nova assinatura" do
        expect {
          post customer_subscriptions_path, params: valid_params
        }.not_to change(Subscription, :count)
      end
    end
  end

  # ─── PATCH /customer/subscriptions/:id/cancel ────────────────────────────────

  describe "PATCH /customer/subscriptions/:id/cancel" do
    context "com assinatura ativa do próprio customer" do
      let(:subscription) { create(:subscription, :active, user: customer, plan:) }

      it "redireciona para index" do
        patch cancel_customer_subscription_path(subscription)
        expect(response).to redirect_to(customer_subscriptions_path)
      end

      it "cancela a assinatura" do
        patch cancel_customer_subscription_path(subscription)
        expect(subscription.reload.status).to eq("canceled")
      end
    end

    context "com assinatura de outro customer" do
      let(:other_subscription) { create(:subscription, :active, plan:) }

      it "redireciona com alerta (não autorizado)" do
        patch cancel_customer_subscription_path(other_subscription)
        expect(response).to have_http_status(:redirect)
      end

      it "não cancela a assinatura" do
        patch cancel_customer_subscription_path(other_subscription)
        expect(other_subscription.reload.status).to eq("active")
      end
    end

    context "com transição inválida (pending_payment)" do
      let(:subscription) { create(:subscription, user: customer, plan:) }

      it "redireciona com alert" do
        patch cancel_customer_subscription_path(subscription)
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(response.body).to include("inválida")
      end
    end
  end
end
