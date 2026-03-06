require "rails_helper"

RSpec.describe PaymentMethod::CreditCard, type: :model do
  subject(:credit_card) { described_class.new }

  describe "#human_name" do
    it { expect(credit_card.human_name).to eq("Cartão de Crédito") }
  end

  describe "#simulate" do
    it "retorna :success" do
      expect(credit_card.simulate(money: Shared::Values::Money.new(cents: 4990, currency: "BRL"))).to eq(:success)
    end

    it "loga no console" do
      expect(Rails.logger).to receive(:info).with(/Cartão de Crédito/)
      credit_card.simulate(money: Shared::Values::Money.new(cents: 4990, currency: "BRL"))
    end
  end

  describe "Registry" do
    it "está registrado com a chave :credit_card" do
      expect(Shared::PaymentMethods::Registry.find(:credit_card)).to eq(described_class)
    end
  end
end
