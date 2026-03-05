require "rails_helper"

RSpec.describe Shared::Values::Money do
  subject(:money) { described_class.new(cents: 990, currency: "BRL") }

  describe "#cents" do
    it "retorna o valor em centavos" do
      expect(money.cents).to eq(990)
    end
  end

  describe "#currency" do
    it "retorna a moeda em maiúsculas" do
      expect(money.currency).to eq("BRL")
    end

    it "normaliza para maiúsculas" do
      expect(described_class.new(cents: 100, currency: "brl").currency).to eq("BRL")
    end
  end

  describe "igualdade" do
    it "é igual a outro Money com mesmos valores" do
      other = described_class.new(cents: 990, currency: "BRL")
      expect(money).to eq(other)
    end

    it "é diferente quando os centavos diferem" do
      other = described_class.new(cents: 1000, currency: "BRL")
      expect(money).not_to eq(other)
    end

    it "é diferente quando a moeda difere" do
      other = described_class.new(cents: 990, currency: "USD")
      expect(money).not_to eq(other)
    end
  end

  describe "comparação" do
    it "é menor que um valor maior" do
      expect(money).to be < described_class.new(cents: 1000, currency: "BRL")
    end

    it "é maior que um valor menor" do
      expect(money).to be > described_class.new(cents: 500, currency: "BRL")
    end
  end

  describe "#to_s" do
    it "formata o valor como moeda" do
      expect(money.to_s).to be_a(String)
      expect(money.to_s).not_to be_empty
    end
  end

  describe "inicialização inválida" do
    it "rejeita centavos não numéricos" do
      expect { described_class.new(cents: "abc", currency: "BRL") }.to raise_error(ArgumentError)
    end
  end
end
