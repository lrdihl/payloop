require "rails_helper"

RSpec.describe PaymentMethod::BankDeposit, type: :model do
  subject(:bank_deposit) { described_class.new }

  describe "#human_name" do
    it { expect(bank_deposit.human_name).to eq("Depósito Bancário") }
  end

  describe "#simulate" do
    it "retorna :success" do
      expect(bank_deposit.simulate(money: Shared::Values::Money.new(cents: 4990, currency: "BRL"))).to eq(:success)
    end

    it "loga no console" do
      expect(Rails.logger).to receive(:info).with(/Depósito Bancário/)
      bank_deposit.simulate(money: Shared::Values::Money.new(cents: 4990, currency: "BRL"))
    end
  end

  describe "Registry" do
    it "está registrado com a chave :bank_deposit" do
      expect(Shared::PaymentMethods::Registry.find(:bank_deposit)).to eq(described_class)
    end
  end
end
