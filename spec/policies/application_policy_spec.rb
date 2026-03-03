require "rails_helper"

RSpec.describe ApplicationPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:user)   { build(:user) }
  let(:record) { double("record") }

  describe "permissões padrão — tudo negado" do
    it { expect(policy.index?).to   be false }
    it { expect(policy.show?).to    be false }
    it { expect(policy.create?).to  be false }
    it { expect(policy.new?).to     be false }
    it { expect(policy.update?).to  be false }
    it { expect(policy.edit?).to    be false }
    it { expect(policy.destroy?).to be false }
  end

  describe "sem usuário autenticado" do
    let(:user) { nil }

    it "levanta NotAuthorizedError" do
      expect { policy }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "Scope#resolve" do
    it "levanta NotImplementedError" do
      expect {
        described_class::Scope.new(user, double).resolve
      }.to raise_error(NotImplementedError)
    end
  end
end
