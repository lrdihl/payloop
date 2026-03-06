require "rails_helper"

RSpec.describe PaymentMethod::Boleto, type: :model do
  subject(:boleto) { described_class.new }

  describe "#human_name" do
    it { expect(boleto.human_name).to eq("Boleto Bancário") }
  end

  describe "#simulate" do
    it "retorna :success" do
      expect(boleto.simulate(money: Shared::Values::Money.new(cents: 4990, currency: "BRL"))).to eq(:success)
    end

    it "loga no console" do
      expect(Rails.logger).to receive(:info).with(/Boleto/)
      boleto.simulate(money: Shared::Values::Money.new(cents: 4990, currency: "BRL"))
    end
  end

  describe "Registry" do
    it "está registrado com a chave :boleto" do
      expect(Shared::PaymentMethods::Registry.find(:boleto)).to eq(described_class)
    end
  end
end
