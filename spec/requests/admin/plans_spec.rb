require "rails_helper"

RSpec.describe "Admin::Plans", type: :request do
  let(:admin)    { create(:user, :admin) }
  let(:customer) { create(:customer_with_profile) }
  let(:plan)     { create(:plan) }

  before { sign_in admin }

  describe "GET /admin/plans" do
    before { plan; get admin_plans_path }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "exibe o nome do plano" do
      expect(response.body).to include(plan.name)
    end

    context "quando customer tenta acessar" do
      before { sign_in customer; get admin_plans_path }

      it "redireciona com alerta" do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "GET /admin/plans/:id" do
    before { get admin_plan_path(plan) }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "exibe o nome do plano" do
      expect(response.body).to include(plan.name)
    end
  end

  describe "GET /admin/plans/new" do
    before { get new_admin_plan_path }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "exibe campos do formulário" do
      expect(response.body).to include("name")
      expect(response.body).to include("price_cents")
    end
  end

  describe "POST /admin/plans" do
    let(:valid_params) do
      {
        plan: {
          name:           "Plano Teste",
          description:    "Descrição",
          price_cents:    4990,
          currency:       "BRL",
          interval_count: 1,
          interval_type:  "month",
          active:         true
        }
      }
    end

    it "cria o plano e redireciona" do
      post admin_plans_path, params: valid_params
      expect(response).to have_http_status(:redirect)
    end

    it "persiste o plano no banco" do
      expect {
        post admin_plans_path, params: valid_params
      }.to change(Plan, :count).by(1)
    end

    it "re-renderiza new com dados inválidos" do
      post admin_plans_path, params: { plan: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /admin/plans/:id/edit" do
    before { get edit_admin_plan_path(plan) }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/plans/:id" do
    it "atualiza o plano e redireciona" do
      patch admin_plan_path(plan), params: { plan: { name: "Nome Novo", price_cents: plan.price_cents, currency: plan.currency, interval_count: plan.interval_count, interval_type: plan.interval_type, active: plan.active } }
      expect(response).to redirect_to(admin_plan_path(plan))
    end

    it "persiste a alteração" do
      patch admin_plan_path(plan), params: { plan: { name: "Nome Novo", price_cents: plan.price_cents, currency: plan.currency, interval_count: plan.interval_count, interval_type: plan.interval_type, active: plan.active } }
      expect(plan.reload.name).to eq("Nome Novo")
    end

    it "re-renderiza edit com dados inválidos" do
      patch admin_plan_path(plan), params: { plan: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /admin/plans/:id" do
    before { plan }

    it "descarta o plano e redireciona" do
      delete admin_plan_path(plan)
      expect(response).to redirect_to(admin_plans_path)
    end

    it "seta discarded_at no plano" do
      delete admin_plan_path(plan)
      expect(plan.reload.discarded_at).not_to be_nil
    end

    it "não remove o registro do banco" do
      expect {
        delete admin_plan_path(plan)
      }.not_to change(Plan, :count)
    end
  end
end
