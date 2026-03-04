# spec/policies/profile_policy_spec.rb
require "rails_helper"

RSpec.describe ProfilePolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:consumer) { create(:user, :consumer) }
  let(:own_profile) { create(:profile, user: consumer) }
  let(:other_profile) { create(:profile) }

  describe "admin" do
    it "pode listar todos os perfis" do expect(ProfilePolicy.new(admin, own_profile).index?).to be true end
    it "pode ver qualquer perfil" do expect(ProfilePolicy.new(admin, other_profile).show?).to be true end
    it "pode editar qualquer perfil" do expect(ProfilePolicy.new(admin, other_profile).update?).to be true end
    it "pode deletar qualquer perfil" do expect(ProfilePolicy.new(admin, other_profile).destroy?).to be true end
    it "NÃO pode criar diretamente" do expect(ProfilePolicy.new(admin, own_profile).create?).to be false end
  end

  describe "consumer com o próprio perfil" do
    it "NÃO pode listar perfis" do expect(ProfilePolicy.new(consumer, own_profile).index?).to be false end
    it "pode ver o próprio perfil" do expect(ProfilePolicy.new(consumer, own_profile).show?).to be true end
    it "pode editar o próprio perfil" do expect(ProfilePolicy.new(consumer, own_profile).update?).to be true end
    it "NÃO pode deletar" do expect(ProfilePolicy.new(consumer, own_profile).destroy?).to be false end
  end

  describe "consumer com perfil de outro usuário" do
    it "NÃO pode ver" do expect(ProfilePolicy.new(consumer, other_profile).show?).to be false end
    it "NÃO pode editar" do expect(ProfilePolicy.new(consumer, other_profile).update?).to be false end
  end
end
