# spec/requests/admin/users_spec.rb
require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  let(:admin)    { create(:user, :admin) }
  let(:consumer) { create(:consumer_with_profile) }

  before { sign_in admin }

  describe "GET /admin/users" do
    before { get admin_users_path }

    it "retorna 200 para admin" do
      expect(response).to have_http_status(:ok)
    end

    it "usa o layout admin" do
      expect(response.body).to include("app-wrapper")
    end

    it "exibe tabela de usuários" do
      consumer # ensure consumer exists
      get admin_users_path
      expect(response.body).to include(consumer.email)
    end

    context "quando consumer tenta acessar" do
      before { sign_in consumer }

      it "redireciona com alerta" do
        get admin_users_path
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "GET /admin/users/:id" do
    before { get admin_user_path(consumer) }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "exibe e-mail do usuário" do
      expect(response.body).to include(consumer.email)
    end

    it "exibe formulário de update_role" do
      expect(response.body).to include("update_role")
    end
  end

  describe "GET /admin/users/:id/edit" do
    before { get edit_admin_user_path(consumer) }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "exibe campos de perfil no formulário" do
      expect(response.body).to include("full_name")
      expect(response.body).to include("document")
      expect(response.body).to include("phone")
    end
  end

  describe "GET /admin/users/new" do
    before { get new_admin_user_path }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "exibe campos de e-mail e senha" do
      expect(response.body).to include('type="email"')
      expect(response.body).to include('type="password"')
    end

    it "exibe campos de perfil" do
      expect(response.body).to include("full_name")
    end
  end

  describe "PATCH /admin/users/:id" do
    let(:params) do
      {
        user: {
          profile_attributes: {
            full_name: "Nome Editado",
            document: consumer.profile.document,
            phone: "47900000000"
          }
        }
      }
    end

    it "atualiza o perfil e redireciona" do
      patch admin_user_path(consumer), params: params
      expect(response).to redirect_to(admin_user_path(consumer))
    end

    it "persiste a alteração" do
      patch admin_user_path(consumer), params: params
      expect(consumer.profile.reload.full_name).to eq("Nome Editado")
    end
  end

  describe "DELETE /admin/users/:id" do
    before { consumer } # força criação antes da contagem

    it "remove o usuário e redireciona" do
      delete admin_user_path(consumer)
      expect(response).to redirect_to(admin_users_path)
    end

    it "diminui o count de usuários" do
      expect {
        delete admin_user_path(consumer)
      }.to change(User, :count).by(-1)
    end
  end

  describe "PATCH /admin/users/:id/role" do
    it "atualiza o role e redireciona" do
      patch update_role_admin_user_path(consumer), params: { role: "admin" }
      expect(response).to redirect_to(admin_user_path(consumer))
    end

    it "persiste o novo role" do
      patch update_role_admin_user_path(consumer), params: { role: "admin" }
      expect(consumer.reload.role).to eq("admin")
    end

    it "não permite admin alterar o próprio role" do
      patch update_role_admin_user_path(admin), params: { role: "consumer" }
      expect(response).to have_http_status(:redirect)
      expect(admin.reload.role).to eq("admin")
    end
  end
end
