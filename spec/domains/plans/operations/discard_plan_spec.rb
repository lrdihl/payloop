require "rails_helper"

RSpec.describe Plans::Operations::DiscardPlan do
  subject(:operation) { described_class.new }

  let(:plan) { create(:plan) }

  # ─── Fluxo feliz ────────────────────────────────────────────────────────────

  describe "com um plano ativo" do
    it "retorna Success com o plano descartado" do
      result = operation.call(plan: plan)
      expect(result).to be_success
      expect(result.value!).to be_a(Plan)
    end

    it "seta discarded_at no plano" do
      operation.call(plan: plan)
      expect(plan.reload.discarded_at).not_to be_nil
    end

    it "não remove o registro do banco" do
      operation.call(plan: plan)
      expect(Plan.with_discarded.find_by(id: plan.id)).not_to be_nil
    end
  end

  # ─── Falha no discard ────────────────────────────────────────────────────────

  describe "quando o discard falha" do
    before { allow(plan).to receive(:discard).and_return(false) }

    it "retorna Failure com tipo :persistence" do
      result = operation.call(plan: plan)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:persistence)
    end
  end
end
