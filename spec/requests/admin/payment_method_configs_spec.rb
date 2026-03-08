require "rails_helper"

RSpec.describe "Admin::PaymentMethodConfigs", type: :request do
  let(:admin)    { create(:user, :admin) }
  let(:customer) { create(:customer_with_profile) }
  let!(:config)  { create(:payment_method_config, key: "boleto", enabled: true) }

  before { sign_in admin }

  # Restaura o Registry após cada teste para não afetar outros
  after do
    Shared::PaymentMethods::Registry.enable(:boleto)
  end

  describe "GET /admin/payment_method_configs" do
    before { get admin_payment_method_configs_path }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    context "quando customer tenta acessar" do
      before { sign_in customer; get admin_payment_method_configs_path }

      it "redireciona" do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "PATCH /admin/payment_method_configs/:id/toggle" do
    context "desativando um método ativo" do
      before { patch toggle_admin_payment_method_config_path(config) }

      it "redireciona para index" do
        expect(response).to redirect_to(admin_payment_method_configs_path)
      end

      it "desativa o config no banco" do
        expect(config.reload.enabled).to be false
      end

      it "desativa o método no Registry" do
        expect(Shared::PaymentMethods::Registry.active?(:boleto)).to be false
      end
    end

    context "ativando um método inativo" do
      let!(:config) { create(:payment_method_config, key: "boleto", enabled: false) }

      before do
        Shared::PaymentMethods::Registry.disable(:boleto)
        patch toggle_admin_payment_method_config_path(config)
      end

      it "redireciona para index" do
        expect(response).to redirect_to(admin_payment_method_configs_path)
      end

      it "ativa o config no banco" do
        expect(config.reload.enabled).to be true
      end

      it "ativa o método no Registry" do
        expect(Shared::PaymentMethods::Registry.active?(:boleto)).to be true
      end
    end

    context "quando customer tenta acessar" do
      before { sign_in customer; patch toggle_admin_payment_method_config_path(config) }

      it "redireciona" do
        expect(response).to have_http_status(:redirect)
      end

      it "não altera o config no banco" do
        expect(config.reload.enabled).to be true
      end
    end
  end
end
