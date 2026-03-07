# spec/requests/customer/profile_spec.rb
require "rails_helper"

RSpec.describe "Customer::Profile", type: :request do
  let(:customer) { create(:customer_with_profile) }
  let(:admin)    { create(:user, :admin) }

  before { sign_in customer }

  # ─── GET /customer/profile ───────────────────────────────────────────────────

  describe "GET /customer/profile" do
    before { get customer_profile_path }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "exibe o e-mail do customer" do
      expect(response.body).to include(customer.email)
    end

    it "exibe o nome do customer" do
      expect(response.body).to include(customer.full_name)
    end

    context "quando admin tenta acessar" do
      before { sign_in admin; get customer_profile_path }

      it "redireciona com alerta" do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  # ─── GET /customer/profile/edit ──────────────────────────────────────────────

  describe "GET /customer/profile/edit" do
    before { get edit_customer_profile_path }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "exibe campos de edição do perfil" do
      expect(response.body).to include("full_name")
      expect(response.body).to include("phone")
    end
  end

  # ─── PATCH /customer/profile ─────────────────────────────────────────────────

  describe "PATCH /customer/profile" do
    let(:params) do
      {
        profile: {
          full_name: "Nome Atualizado",
          document:  customer.profile.document,
          phone:     "47999990000"
        }
      }
    end

    it "atualiza o perfil e redireciona" do
      patch customer_profile_path, params: params
      expect(response).to redirect_to(customer_profile_path)
    end

    it "persiste a alteração" do
      patch customer_profile_path, params: params
      expect(customer.profile.reload.full_name).to eq("Nome Atualizado")
    end

    context "com dados inválidos" do
      it "retorna 422" do
        patch customer_profile_path, params: { profile: { full_name: "", document: "", phone: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
