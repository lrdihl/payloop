# spec/requests/home_spec.rb
require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    context "quando não autenticado" do
      it "redireciona para login" do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "quando autenticado como admin" do
      before { sign_in create(:user, :admin) }

      it "redireciona para admin_root_path" do
        get root_path
        expect(response).to redirect_to(admin_root_path)
      end
    end

    context "quando autenticado como customer" do
      before { sign_in create(:user, :customer) }

      it "redireciona para customer_root_path" do
        get root_path
        expect(response).to redirect_to(customer_root_path)
      end
    end
  end
end
