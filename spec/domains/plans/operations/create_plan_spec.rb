require "rails_helper"

RSpec.describe Plans::Operations::CreatePlan do
  subject(:operation) { described_class.new }

  let(:valid_params) do
    {
      name:           "Plano Mensal",
      description:    "Acesso completo por 1 mês",
      price_cents:    4990,
      currency:       "BRL",
      interval_count: 1,
      interval_type:  "month",
      active:         true
    }
  end

  # ─── Fluxo feliz ────────────────────────────────────────────────────────────

  describe "com dados válidos" do
    it "retorna Success com o plano criado" do
      result = operation.call(valid_params)
      expect(result).to be_success
      expect(result.value!).to be_a(Plan)
    end

    it "persiste o plano no banco" do
      expect { operation.call(valid_params) }.to change(Plan, :count).by(1)
    end

    it "persiste os atributos corretamente" do
      operation.call(valid_params)
      plan = Plan.last
      expect(plan.name).to eq("Plano Mensal")
      expect(plan.price_cents).to eq(4990)
      expect(plan.currency).to eq("BRL")
    end
  end

  # ─── Falha no step :validate ────────────────────────────────────────────────

  describe "com dados inválidos" do
    it "retorna Failure com tipo :validation quando name está ausente" do
      result = operation.call(valid_params.except(:name))
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
      expect(result.failure[:errors][:name]).not_to be_empty
    end

    it "retorna Failure com tipo :validation quando price_cents é negativo" do
      result = operation.call(valid_params.merge(price_cents: -1))
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
    end

    it "não persiste o plano quando a validação falha" do
      expect { operation.call(valid_params.except(:name)) }.not_to change(Plan, :count)
    end
  end

  # ─── Falha no step :persist ──────────────────────────────────────────────────

  describe "quando a persistência falha" do
    before { allow_any_instance_of(Plan).to receive(:save).and_return(false) }

    it "retorna Failure com tipo :persistence" do
      result = operation.call(valid_params)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:persistence)
    end
  end
end
