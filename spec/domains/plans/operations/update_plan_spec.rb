require "rails_helper"

RSpec.describe Plans::Operations::UpdatePlan do
  subject(:operation) { described_class.new }

  let(:plan) { create(:plan, name: "Plano Original", price_cents: 1990) }

  let(:valid_params) do
    {
      plan:           plan,
      name:           "Plano Atualizado",
      description:    "Nova descrição",
      price_cents:    4990,
      currency:       "BRL",
      interval_count: 1,
      interval_type:  "month",
      active:         true
    }
  end

  # ─── Fluxo feliz ────────────────────────────────────────────────────────────

  describe "com dados válidos" do
    it "retorna Success com o plano atualizado" do
      result = operation.call(valid_params)
      expect(result).to be_success
      expect(result.value!).to be_a(Plan)
    end

    it "persiste as alterações no banco" do
      operation.call(valid_params)
      expect(plan.reload.name).to eq("Plano Atualizado")
      expect(plan.reload.price_cents).to eq(4990)
    end
  end

  # ─── Falha no step :validate ────────────────────────────────────────────────

  describe "com dados inválidos" do
    it "retorna Failure com tipo :validation quando name está ausente" do
      result = operation.call(valid_params.merge(name: nil))
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
    end

    it "não altera o plano quando a validação falha" do
      operation.call(valid_params.merge(price_cents: -1))
      expect(plan.reload.name).to eq("Plano Original")
    end
  end

  # ─── Falha no step :persist ──────────────────────────────────────────────────

  describe "quando a persistência falha" do
    before { allow(plan).to receive(:update).and_return(false) }

    it "retorna Failure com tipo :persistence" do
      result = operation.call(valid_params)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:persistence)
    end
  end
end
