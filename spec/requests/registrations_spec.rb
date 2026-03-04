# spec/requests/registrations_spec.rb
require "rails_helper"

RSpec.describe "Registrations", type: :request do
  let(:valid_params) do
    {
      user: {
        email: "novo@exemplo.com",
        password: "senha@123",
        password_confirmation: "senha@123",
        profile_attributes: {
          full_name: "Maria Oliveira",
          document: "12345678901",
          phone: "47988887777"
        }
      }
    }
  end

  describe "GET /users/cadastro" do
    it "retorna 200" do
      get new_user_registration_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    context "com dados válidos" do
      it "cria o usuário e redireciona" do
        expect {
          post user_registration_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "cria o profile vinculado" do
        expect {
          post user_registration_path, params: valid_params
        }.to change(Profile, :count).by(1)
      end

      it "redireciona após registro" do
        post user_registration_path, params: valid_params
        expect(response).to have_http_status(:redirect)
      end
    end

    context "com email inválido" do
      it "não cria usuário" do
        invalid = valid_params.deep_merge(user: { email: "nao-é-email" })
        expect {
          post user_registration_path, params: invalid
        }.not_to change(User, :count)
      end

      it "retorna 422" do
        invalid = valid_params.deep_merge(user: { email: "nao-é-email" })
        post user_registration_path, params: invalid
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "com senha muito curta" do
      it "não cria usuário" do
        invalid = valid_params.deep_merge(user: { password: "123", password_confirmation: "123" })
        expect {
          post user_registration_path, params: invalid
        }.not_to change(User, :count)
      end
    end

    context "com email já existente" do
      before { create(:user, email: "novo@exemplo.com") }

      it "não cria usuário duplicado" do
        expect {
          post user_registration_path, params: valid_params
        }.not_to change(User, :count)
      end
    end
  end
end
