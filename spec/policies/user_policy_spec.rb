# spec/policies/user_policy_spec.rb
require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  subject(:policy) { described_class }

  let(:admin)    { build(:user, :admin) }
  let(:consumer) { build(:user, :consumer) }
  let(:other)    { build(:user, :consumer) }

  # ─── Admin: acesso total ─────────────────────────────────────────────────────
  describe "admin" do
    it "pode listar todos os usuários" do expect(policy).to permit(admin, other).for_action(:index?) end
    it "pode ver qualquer usuário" do expect(policy).to permit(admin, other).for_action(:show?) end
    it "pode criar usuários" do expect(policy).to permit(admin, other).for_action(:create?) end
    it "pode editar qualquer usuário" do expect(policy).to permit(admin, other).for_action(:update?) end
    it "pode deletar qualquer usuário" do expect(policy).to permit(admin, other).for_action(:destroy?) end
    it "pode alterar role de outros" do expect(policy).to permit(admin, other).for_action(:update_role?) end
    it "NÃO pode alterar o próprio role" do expect(policy).not_to permit(admin, admin).for_action(:update_role?) end
  end

  # ─── Consumer: acesso apenas ao próprio registro ─────────────────────────────
  describe "consumer acessando o próprio registro" do
    it "NÃO pode listar usuários" do expect(policy).not_to permit(consumer, consumer).for_action(:index?) end
    it "pode ver a si mesmo" do expect(policy).to permit(consumer, consumer).for_action(:show?) end
    it "NÃO pode criar usuários via admin" do expect(policy).not_to permit(consumer, consumer).for_action(:create?) end
    it "pode editar a si mesmo" do expect(policy).to permit(consumer, consumer).for_action(:update?) end
    it "NÃO pode deletar a si mesmo" do expect(policy).not_to permit(consumer, consumer).for_action(:destroy?) end
    it "NÃO pode alterar roles" do expect(policy).not_to permit(consumer, consumer).for_action(:update_role?) end
  end

  describe "consumer acessando outro usuário" do
    it "NÃO pode ver outro usuário" do expect(policy).not_to permit(consumer, other).for_action(:show?) end
    it "NÃO pode editar outro usuário" do expect(policy).not_to permit(consumer, other).for_action(:update?) end
    it "NÃO pode deletar outro usuário" do expect(policy).not_to permit(consumer, other).for_action(:destroy?) end
  end

  # ─── Scope ───────────────────────────────────────────────────────────────────
  describe "Scope" do
    let!(:user1) { create(:user, :consumer) }
    let!(:user2) { create(:user, :consumer) }
    let!(:admin_user) { create(:user, :admin) }

    it "admin resolve todos os usuários" do
      scope = described_class::Scope.new(admin_user, User).resolve
      expect(scope).to include(user1, user2, admin_user)
    end

    it "consumer resolve apenas o próprio usuário" do
      scope = described_class::Scope.new(user1, User).resolve
      expect(scope).to contain_exactly(user1)
    end
  end

  # ─── Usuário não autenticado ─────────────────────────────────────────────────
  describe "sem usuário autenticado" do
    it "levanta NotAuthorizedError" do
      expect { described_class.new(nil, other) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
