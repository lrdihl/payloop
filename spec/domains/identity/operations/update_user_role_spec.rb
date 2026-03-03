# spec/domains/identity/operations/update_user_role_spec.rb
require "rails_helper"

RSpec.describe Identity::Operations::UpdateUserRole do
  subject(:operation) { described_class.new }

  let(:user) { create(:user, :consumer) }

  # ─── Fluxo feliz ────────────────────────────────────────────────────────────
  describe "promovendo consumer para admin" do
    it "retorna Success com o user atualizado" do
      result = operation.call(user:, role: "admin")
      expect(result).to be_success
      expect(result.value!).to be_a(User)
    end

    it "persiste o novo role" do
      operation.call(user:, role: "admin")
      expect(user.reload.role).to eq("admin")
    end
  end

  describe "rebaixando admin para consumer" do
    let(:user) { create(:user, :admin) }

    it "retorna Success" do
      result = operation.call(user:, role: "consumer")
      expect(result).to be_success
    end

    it "persiste o novo role" do
      operation.call(user:, role: "consumer")
      expect(user.reload.role).to eq("consumer")
    end
  end

  # ─── Falha de validação ──────────────────────────────────────────────────────
  describe "com role inválido" do
    it "retorna Failure com tipo :validation" do
      result = operation.call(user:, role: "superadmin")
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
      expect(result.failure[:errors][:role]).not_to be_empty
    end

    it "não altera o role do usuário" do
      operation.call(user:, role: "invalido")
      expect(user.reload.role).to eq("consumer")
    end
  end

  describe "com role em branco" do
    it "retorna Failure com tipo :validation" do
      result = operation.call(user:, role: "")
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
    end
  end
end
