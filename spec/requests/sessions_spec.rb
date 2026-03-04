# spec/requests/sessions_spec.rb
require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /users/sign_in" do
    before { get new_user_session_path }

    it "retorna 200" do
      expect(response).to have_http_status(:ok)
    end

    it "exibe campo de e-mail" do
      expect(response.body).to include('type="email"')
    end

    it "exibe campo de senha" do
      expect(response.body).to include('type="password"')
    end

    it "usa o layout auth" do
      expect(response.body).to include("login-box")
    end

    it "exibe link para cadastro" do
      expect(response.body).to include(new_user_registration_path)
    end
  end

  describe "POST /users/sign_in" do
    context "com credenciais válidas" do
      it "redireciona após login" do
        post user_session_path, params: { user: { email: user.email, password: "senha@123" } }
        expect(response).to have_http_status(:redirect)
      end
    end

    context "com credenciais inválidas" do
      it "retorna 422" do
        post user_session_path, params: { user: { email: user.email, password: "errada" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
