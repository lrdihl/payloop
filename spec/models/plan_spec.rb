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

  describe "value object price" do
    let(:plan) { described_class.new(price_cents: 1990, currency: "BRL") }

    it "plan.price retorna um Money" do
      expect(plan.price).to be_a(Shared::Values::Money)
    end

    it "plan.price.cents reflete price_cents" do
      expect(plan.price.cents).to eq(1990)
    end

    it "plan.price.currency reflete currency" do
      expect(plan.price.currency).to eq("BRL")
    end
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

  describe "duration e renewable" do
    subject do
      described_class.new(
        name: "Plano",
        price_cents: 990,
        currency: "BRL",
        interval_count: 1,
        interval_type: "month",
        active: true,
        duration_count: 12,
        duration_type: "month",
        renewable: false
      )
    end

    it { is_expected.to validate_inclusion_of(:duration_type).in_array(%w[month year]).allow_nil }
    it { is_expected.to validate_numericality_of(:duration_count).is_greater_than(0).only_integer.allow_nil }

    it "permite duration nil/nil (vitalício)" do
      plan = Plan.new(subject.attributes.merge("duration_count" => nil, "duration_type" => nil))
      expect(plan).to be_valid
    end

    it "rejeita duration_count preenchido sem duration_type" do
      plan = Plan.new(subject.attributes.merge("duration_type" => nil))
      expect(plan).not_to be_valid
      expect(plan.errors[:duration_type]).not_to be_empty
    end

    it "rejeita duration_type preenchido sem duration_count" do
      plan = Plan.new(subject.attributes.merge("duration_count" => nil))
      expect(plan).not_to be_valid
      expect(plan.errors[:duration_count]).not_to be_empty
    end

    it "renewable é false por padrão" do
      expect(Plan.new.renewable).to be false
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
