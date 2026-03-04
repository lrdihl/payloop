# spec/requests/admin/users_spec.rb
require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  let(:admin)    { create(:user, :admin) }
  let(:consumer) { create(:consumer_with_profile) }

  before { sign_in admin }

  describe "GET /admin/users" do
    it "retorna 200 para admin" do
      get admin_users_path
      expect(response).to have_http_status(:ok)
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
    it "retorna 200" do
      get admin_user_path(consumer)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /admin/users/:id/edit" do
    it "retorna 200" do
      get edit_admin_user_path(consumer)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/users/:id" do
    let(:params) do
      {
        user: {
          profile_attributes: {
            full_name: "Nome Editado",
            document:  consumer.profile.document,
            phone:     "47900000000"
          }
        }
      }
    end

    it "atualiza o perfil e redireciona" do
      patch admin_user_path(consumer), params:
      expect(response).to redirect_to(admin_user_path(consumer))
    end

    it "persiste a alteração" do
      patch admin_user_path(consumer), params:
      expect(consumer.profile.reload.full_name).to eq("Nome Editado")
    end
  end

  describe "DELETE /admin/users/:id" do
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
