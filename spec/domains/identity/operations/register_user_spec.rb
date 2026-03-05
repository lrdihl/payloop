require "rails_helper"

RSpec.describe Identity::Operations::RegisterUser do
  subject(:operation) { described_class.new }

  let(:valid_params) do
    {
      email:                 "novo@exemplo.com",
      password:              "senha@123",
      password_confirmation: "senha@123",
      full_name:             "Maria Oliveira",
      document:              "98765432100",
      phone:                 "47988887777"
    }
  end

  # ─── Fluxo feliz ────────────────────────────────────────────────────────────

  describe "com dados válidos" do
    it "retorna Success com o profile criado" do
      result = operation.call(valid_params)
      expect(result).to be_success
      expect(result.value!).to be_a(Profile)
    end

    it "cria um User com role consumer por padrão" do
      operation.call(valid_params)
      user = User.find_by(email: valid_params[:email])
      expect(user).not_to be_nil
      expect(user.role).to eq("consumer")
    end

    it "cria um User com role admin quando informado" do
      operation.call(valid_params.merge(role: "admin"))
      user = User.find_by(email: valid_params[:email])
      expect(user.role).to eq("admin")
    end

    it "cria um Profile vinculado ao User" do
      result  = operation.call(valid_params)
      profile = result.value!
      expect(profile.full_name).to eq("Maria Oliveira")
      expect(profile.user.email).to eq("novo@exemplo.com")
    end
  end

  # ─── Falha no step :validate ────────────────────────────────────────────────

  describe "com dados inválidos" do
    it "retorna Failure com tipo :validation" do
      result = operation.call(valid_params.merge(email: "nao-é-email"))
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
      expect(result.failure[:errors][:email]).not_to be_empty
    end

    it "não cria User quando a validação falha" do
      operation.call(valid_params.merge(password: "123"))
      expect(User.find_by(email: valid_params[:email])).to be_nil
    end
  end

  # ─── Falha no step :create_user ─────────────────────────────────────────────

  describe "quando o email já existe" do
    before { create(:user, email: valid_params[:email]) }

    it "retorna Failure com tipo :persistence" do
      result = operation.call(valid_params)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:persistence)
    end
  end

  # ─── Falha no step :create_profile ──────────────────────────────────────────

  describe "quando o documento já está em uso" do
    before do
      existing_user = create(:user)
      create(:profile, user: existing_user, document: valid_params[:document])
    end

    it "retorna Failure e faz rollback do usuário criado" do
      expect { operation.call(valid_params) }.not_to change(User, :count)
    end

    it "retorna tipo :persistence" do
      result = operation.call(valid_params)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:persistence)
    end
  end
end
