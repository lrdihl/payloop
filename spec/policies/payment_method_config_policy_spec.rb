require "rails_helper"

RSpec.describe PaymentMethodConfigPolicy, type: :policy do
  let(:admin)    { build(:user, :admin) }
  let(:customer) { build(:user, :customer) }
  let(:config)   { build(:payment_method_config) }

  describe "admin" do
    it "pode listar configs"   do expect(described_class.new(admin, config).index?).to be true end
    it "pode atualizar config" do expect(described_class.new(admin, config).update?).to be true end
  end

  describe "customer" do
    it "NÃO pode listar configs"   do expect(described_class.new(customer, config).index?).to be false end
    it "NÃO pode atualizar config" do expect(described_class.new(customer, config).update?).to be false end
  end
end
