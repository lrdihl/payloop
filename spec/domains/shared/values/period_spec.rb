# spec/domains/shared/values/period_spec.rb
require "rails_helper"

RSpec.describe Shared::Values::Period do
  describe "#advance_from" do
    it "avança 1 mês respeitando o último dia de fevereiro" do
      period = described_class.new(count: 1, type: "month")
      expect(period.advance_from(Date.new(2025, 1, 31))).to eq(Date.new(2025, 2, 28))
    end

    it "avança 3 meses cruzando virada de ano" do
      period = described_class.new(count: 3, type: "month")
      expect(period.advance_from(Date.new(2025, 11, 30))).to eq(Date.new(2026, 2, 28))
    end

    it "avança 1 ano a partir de 29/fev em ano bissexto" do
      period = described_class.new(count: 1, type: "year")
      expect(period.advance_from(Date.new(2024, 2, 29))).to eq(Date.new(2025, 2, 28))
    end
  end

  describe "#lifetime?" do
    it "retorna true quando count e type são nil" do
      period = described_class.new(count: nil, type: nil)
      expect(period.lifetime?).to be true
    end

    it "retorna false quando count e type estão preenchidos" do
      period = described_class.new(count: 1, type: "month")
      expect(period.lifetime?).to be false
    end
  end

  describe "#advance_from com período vitalício" do
    it "retorna nil" do
      period = described_class.new(count: nil, type: nil)
      expect(period.advance_from(Date.current)).to be_nil
    end
  end
end
