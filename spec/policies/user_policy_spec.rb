# spec/policies/user_policy_spec.rb
require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:admin)    { build(:user, :admin) }
  let(:consumer) { build(:user, :consumer) }
  let(:other)    { build(:user, :consumer) }

  # ─── Admin: acesso total ─────────────────────────────────────────────────────
  describe "admin" do
    it "pode listar todos os usuários"   do expect(UserPolicy.new(admin, other).index?).to be true end
    it "pode ver qualquer usuário"       do expect(UserPolicy.new(admin, other).show?).to be true end
    it "pode criar usuários"             do expect(UserPolicy.new(admin, other).create?).to be true end
    it "pode editar qualquer usuário"    do expect(UserPolicy.new(admin, other).update?).to be true end
    it "pode deletar qualquer usuário"   do expect(UserPolicy.new(admin, other).destroy?).to be true end
    it "pode alterar role de outros"     do expect(UserPolicy.new(admin, other).update_role?).to be true end
    it "NÃO pode alterar o próprio role" do expect(UserPolicy.new(admin, admin).update_role?).to be false end
  end

  # ─── Consumer: acesso apenas ao próprio registro ─────────────────────────────
  describe "consumer acessando o próprio registro" do
    it "NÃO pode listar usuários"          do expect(UserPolicy.new(consumer, consumer).index?).to be false end
    it "pode ver a si mesmo"               do expect(UserPolicy.new(consumer, consumer).show?).to be true end
    it "NÃO pode criar usuários via admin" do expect(UserPolicy.new(consumer, consumer).create?).to be false end
    it "pode editar a si mesmo"            do expect(UserPolicy.new(consumer, consumer).update?).to be true end
    it "NÃO pode deletar a si mesmo"       do expect(UserPolicy.new(consumer, consumer).destroy?).to be false end
    it "NÃO pode alterar roles"            do expect(UserPolicy.new(consumer, consumer).update_role?).to be false end
  end

  describe "consumer acessando outro usuário" do
    it "NÃO pode ver outro usuário"        do expect(UserPolicy.new(consumer, other).show?).to be false end
    it "NÃO pode editar outro usuário"     do expect(UserPolicy.new(consumer, other).update?).to be false end
    it "NÃO pode deletar outro usuário"    do expect(UserPolicy.new(consumer, other).destroy?).to be false end
  end

  # ─── Scope ───────────────────────────────────────────────────────────────────
  describe "Scope" do
    let!(:user1)      { create(:user, :consumer) }
    let!(:user2)      { create(:user, :consumer) }
    let!(:admin_user) { create(:user, :admin) }

    it "admin resolve todos os usuários" do
      scope = UserPolicy::Scope.new(admin_user, User).resolve
      expect(scope).to include(user1, user2, admin_user)
    end

    it "consumer resolve apenas o próprio usuário" do
      scope = UserPolicy::Scope.new(user1, User).resolve
      expect(scope).to contain_exactly(user1)
    end
  end

  # ─── Usuário não autenticado ─────────────────────────────────────────────────
  describe "sem usuário autenticado" do
    it "levanta NotAuthorizedError" do
      expect { UserPolicy.new(nil, other) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
