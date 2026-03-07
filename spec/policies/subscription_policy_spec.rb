# spec/policies/subscription_policy_spec.rb
require "rails_helper"

RSpec.describe SubscriptionPolicy, type: :policy do
  let(:admin)        { build(:user, :admin) }
  let(:customer)     { build(:user, :customer) }
  let(:subscription) { build(:subscription) }

  # ─── Admin: acesso total ─────────────────────────────────────────────────────

  describe "admin" do
    subject(:policy) { described_class.new(admin, subscription) }

    it { expect(policy.index?).to be true }
    it { expect(policy.show?).to be true }
    it { expect(policy.create?).to be true }
    it { expect(policy.activate?).to be true }
    it { expect(policy.fail?).to be true }
    it { expect(policy.retry?).to be true }
    it { expect(policy.cancel?).to be true }
    it { expect(policy.close?).to be true }
  end

  # ─── Customer: acesso negado ──────────────────────────────────────────────────

  describe "customer" do
    subject(:policy) { described_class.new(customer, subscription) }

    it { expect(policy.index?).to be false }
    it { expect(policy.show?).to be false }
    it { expect(policy.create?).to be false }
    it { expect(policy.activate?).to be false }
    it { expect(policy.fail?).to be false }
    it { expect(policy.retry?).to be false }
    it { expect(policy.cancel?).to be false }
    it { expect(policy.close?).to be false }
  end

  # ─── Scope ───────────────────────────────────────────────────────────────────

  describe "Scope" do
    let!(:sub1) { create(:subscription) }
    let!(:sub2) { create(:subscription) }

    it "admin resolve todas as assinaturas" do
      scope = described_class::Scope.new(admin, Subscription).resolve
      expect(scope).to include(sub1, sub2)
    end

    it "customer resolve nenhuma assinatura" do
      scope = described_class::Scope.new(customer, Subscription).resolve
      expect(scope).to be_empty
    end
  end

  # ─── Sem usuário autenticado ─────────────────────────────────────────────────

  describe "sem usuário autenticado" do
    it "levanta NotAuthorizedError" do
      expect { described_class.new(nil, subscription) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
