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

  # ─── Customer: acesso parcial ────────────────────────────────────────────────

  describe "customer acessando a própria assinatura" do
    let(:own_subscription) { build(:subscription, user: customer) }
    subject(:policy) { described_class.new(customer, own_subscription) }

    it { expect(policy.index?).to be true }
    it { expect(policy.show?).to be true }
    it { expect(policy.create?).to be true }
    it { expect(policy.cancel?).to be true }
    it { expect(policy.close?).to be false }
    it { expect(policy.activate?).to be false }
    it { expect(policy.fail?).to be false }
    it { expect(policy.retry?).to be false }
  end

  describe "customer acessando assinatura de outro usuário" do
    subject(:policy) { described_class.new(customer, subscription) }

    it { expect(policy.show?).to be false }
    it { expect(policy.cancel?).to be false }
  end

  # ─── Scope ───────────────────────────────────────────────────────────────────

  describe "Scope" do
    let(:customer_persisted) { create(:user, :customer) }
    let(:other_customer)     { create(:user, :customer) }
    let!(:own_sub)   { create(:subscription, user: customer_persisted) }
    let!(:other_sub) { create(:subscription, user: other_customer) }

    it "admin resolve todas as assinaturas" do
      scope = described_class::Scope.new(admin, Subscription).resolve
      expect(scope).to include(own_sub, other_sub)
    end

    it "customer resolve apenas suas próprias assinaturas" do
      scope = described_class::Scope.new(customer_persisted, Subscription).resolve
      expect(scope).to contain_exactly(own_sub)
    end

    it "customer não vê assinaturas de outros" do
      scope = described_class::Scope.new(customer_persisted, Subscription).resolve
      expect(scope).not_to include(other_sub)
    end
  end

  # ─── Sem usuário autenticado ─────────────────────────────────────────────────

  describe "sem usuário autenticado" do
    it "levanta NotAuthorizedError" do
      expect { described_class.new(nil, subscription) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
