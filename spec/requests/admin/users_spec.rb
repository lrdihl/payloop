# spec/requests/admin/users_spec.rb
require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  let(:admin)    { create(:user, :admin) }
  let(:customer) { create(:customer_with_profile) }

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
      customer # ensure customer exists
      get admin_users_path
      expect(response.body).to include(customer.email)
    end

    context "quando customer tenta acessar" do
      before { sign_in customer; get admin_users_path }

      it "redireciona com alerta" do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "GET /admin/users/:id" do
    before { get admin_user_path(customer) }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "exibe e-mail do usuário" do
      expect(response.body).to include(customer.email)
    end

    it "não exibe formulário de update_role no show" do
      expect(response.body).not_to include("update_role")
    end
  end

  describe "GET /admin/users/:id/edit" do
    before { get edit_admin_user_path(customer) }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "exibe campos de perfil no formulário" do
      expect(response.body).to include("full_name")
      expect(response.body).to include("document")
      expect(response.body).to include("phone")
    end

    it "exibe select de tipo (role) para admin" do
      expect(response.body).to include("user[role]")
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

    it "exibe campo de seleção de role" do
      expect(response.body).to include('name="user[role]"')
    end
  end

  describe "POST /admin/users" do
    let(:base_params) do
      {
        user: {
          email:    "novo@exemplo.com",
          password: "senha@123",
          role:     "customer",
          profile_attributes: {
            full_name: "Novo Usuário",
            document:  "12345678901",
            phone:     "47999999999"
          }
        }
      }
    end

    it "cria usuário customer por padrão e redireciona" do
      post admin_users_path, params: base_params
      user = User.find_by(email: "novo@exemplo.com")
      expect(user.role).to eq("customer")
      expect(response).to have_http_status(:redirect)
    end

    it "cria usuário admin quando role: admin é informado" do
      post admin_users_path, params: base_params.deep_merge(user: { role: "admin" })
      user = User.find_by(email: "novo@exemplo.com")
      expect(user.role).to eq("admin")
    end
  end

  describe "PATCH /admin/users/:id" do
    let(:params) do
      {
        user: {
          profile_attributes: {
            full_name: "Nome Editado",
            document: customer.profile.document,
            phone: "47900000000"
          }
        }
      }
    end

    it "atualiza o perfil e redireciona" do
      patch admin_user_path(customer), params: params
      expect(response).to redirect_to(admin_user_path(customer))
    end

    it "persiste a alteração" do
      patch admin_user_path(customer), params: params
      expect(customer.profile.reload.full_name).to eq("Nome Editado")
    end
  end

  describe "DELETE /admin/users/:id" do
    before { customer } # força criação antes da contagem

    it "remove o usuário e redireciona" do
      delete admin_user_path(customer)
      expect(response).to redirect_to(admin_users_path)
    end

    it "diminui o count de usuários" do
      expect {
        delete admin_user_path(customer)
      }.to change(User, :count).by(-1)
    end
  end

  describe "ações restritas para customer" do
    let(:outro_usuario) { create(:user, :admin) }

    before { sign_in customer }

    it "GET /admin/users/new → redireciona com alerta" do
      get new_admin_user_path
      expect(response).to have_http_status(:redirect)
    end

    it "GET /admin/users/:outro_id → redireciona com alerta" do
      get admin_user_path(outro_usuario)
      expect(response).to have_http_status(:redirect)
    end

    it "DELETE /admin/users/:id → redireciona com alerta" do
      delete admin_user_path(outro_usuario)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "PATCH /admin/users/:id/role" do
    it "atualiza o role e redireciona" do
      patch update_role_admin_user_path(customer), params: { role: "admin" }
      expect(response).to redirect_to(admin_user_path(customer))
    end

    it "persiste o novo role" do
      patch update_role_admin_user_path(customer), params: { role: "admin" }
      expect(customer.reload.role).to eq("admin")
    end

    it "não permite admin alterar o próprio role" do
      patch update_role_admin_user_path(admin), params: { role: "customer" }
      expect(response).to have_http_status(:redirect)
      expect(admin.reload.role).to eq("admin")
    end
  end
end
