# spec/models/plan_spec.rb
require "rails_helper"

RSpec.describe Plan, type: :model do
  describe "validações" do
    subject do
      described_class.new(
        name: "Plano Básico",
        price_cents: 990,
        currency: "BRL",
        interval_count: 1,
        interval_type: "month",
        active: true
      )
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:price_cents) }
    it { is_expected.to validate_numericality_of(:price_cents).is_greater_than(0).only_integer }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(%w[BRL USD]) }
    it { is_expected.to validate_presence_of(:interval_count) }
    it { is_expected.to validate_numericality_of(:interval_count).is_greater_than(0).only_integer }
    it { is_expected.to validate_presence_of(:interval_type) }
    it { is_expected.to validate_inclusion_of(:interval_type).in_array(%w[month year]) }
  end

  describe "escopos" do
    let!(:plano_ativo)   { create(:plan, active: true) }
    let!(:plano_inativo) { create(:plan, active: false) }

    describe ".active" do
      it "retorna apenas planos ativos" do
        expect(Plan.active).to include(plano_ativo)
        expect(Plan.active).not_to include(plano_inativo)
      end
    end

    describe ".inactive" do
      it "retorna apenas planos inativos" do
        expect(Plan.inactive).to include(plano_inativo)
        expect(Plan.inactive).not_to include(plano_ativo)
      end
    end
  end

  describe "soft delete (discard)" do
    let(:plan) { create(:plan) }

    it "pode ser descartado via discard" do
      plan.discard
      expect(plan.discarded?).to be true
      expect(Plan.kept).not_to include(plan)
    end
  end
end
