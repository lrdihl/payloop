# spec/controllers/application_controller_spec.rb
require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    include Dry::Monads[:result]

    skip_before_action :authenticate_user!

    def index
      raise Pundit::NotAuthorizedError, "test"
    end

    def show
      render plain: "ok"
    end

    def create
      handle_result(Success("ok")) { render plain: "success" }
    end

    def update
      handle_result(Failure({ type: :validation, errors: { name: [ "inválido" ] } })) { }
    end

    def destroy
      handle_result(Failure({ type: :persistence, errors: { base: [ "erro" ] } })) { }
    end

    def edit
      handle_result(Failure("erro genérico")) { }
    end
  end

  before do
    routes.draw do
      get  "anonymous/index"   => "anonymous#index"
      get  "anonymous/show"    => "anonymous#show",  as: :root
      post "anonymous/create"  => "anonymous#create"
      put  "anonymous/update"  => "anonymous#update"
      delete "anonymous/destroy" => "anonymous#destroy"
      get "anonymous/edit"    => "anonymous#edit"
    end
  end

  describe "#handle_unauthorized" do
    it "redireciona para root com mensagem de alerta" do
      get :index
      expect(response).to redirect_to("/")
      expect(flash[:alert]).to eq("Você não tem permissão para realizar esta ação.")
    end
  end

  describe "#handle_result" do
    context "com Success" do
      it "executa o bloco de sucesso" do
        post :create
        expect(response.body).to eq("success")
      end
    end

    context "com Failure :validation" do
      it "renderiza com status unprocessable_entity" do
        put :update, format: :json
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)["errors"]).to eq({ "name" => [ "inválido" ] })
      end
    end

    context "com Failure :persistence" do
      it "renderiza com status unprocessable_entity" do
        delete :destroy, format: :json
        expect(response.status).to eq(422)
      end
    end

    context "com Failure genérico" do
      it "renderiza com status unprocessable_entity" do
        get :edit, format: :json
        expect(response.status).to eq(422)
      end
    end
  end

  describe "#action_for_failure" do
    it "retorna :new por padrão" do
      expect(controller.send(:action_for_failure)).to eq(:new)
    end
  end
end
