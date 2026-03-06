require "rails_helper"

RSpec.describe PlanPolicy, type: :policy do
  let(:admin)    { build(:user, :admin) }
  let(:customer) { build(:user, :customer) }
  let(:plan)     { build(:plan) }

  # ─── Admin: acesso total ─────────────────────────────────────────────────────
  describe "admin" do
    it "pode listar planos"  do expect(PlanPolicy.new(admin, plan).index?).to be true end
    it "pode ver um plano"   do expect(PlanPolicy.new(admin, plan).show?).to be true end
    it "pode criar planos"   do expect(PlanPolicy.new(admin, plan).create?).to be true end
    it "pode editar planos"  do expect(PlanPolicy.new(admin, plan).update?).to be true end
    it "pode destruir planos" do expect(PlanPolicy.new(admin, plan).destroy?).to be true end
  end

  # ─── Customer: sem acesso ────────────────────────────────────────────────────
  describe "customer" do
    it "NÃO pode listar planos"   do expect(PlanPolicy.new(customer, plan).index?).to be false end
    it "NÃO pode ver um plano"    do expect(PlanPolicy.new(customer, plan).show?).to be false end
    it "NÃO pode criar planos"    do expect(PlanPolicy.new(customer, plan).create?).to be false end
    it "NÃO pode editar planos"   do expect(PlanPolicy.new(customer, plan).update?).to be false end
    it "NÃO pode destruir planos" do expect(PlanPolicy.new(customer, plan).destroy?).to be false end
  end

  # ─── Scope ───────────────────────────────────────────────────────────────────
  describe "Scope" do
    let!(:plan1) { create(:plan) }
    let!(:plan2) { create(:plan, :inactive) }

    it "admin resolve todos os planos" do
      scope = PlanPolicy::Scope.new(admin, Plan).resolve
      expect(scope).to include(plan1, plan2)
    end

    it "customer resolve escopo vazio" do
      scope = PlanPolicy::Scope.new(customer, Plan).resolve
      expect(scope).to be_empty
    end
  end
end
