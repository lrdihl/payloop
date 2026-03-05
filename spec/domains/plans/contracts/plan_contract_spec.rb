require "rails_helper"

RSpec.describe Plans::Contracts::PlanContract do
  subject(:contract) { described_class.new }

  let(:valid_input) do
    {
      name:           "Plano Básico",
      description:    "Plano de entrada",
      price_cents:    990,
      currency:       "BRL",
      interval_count: 1,
      interval_type:  "month",
      active:         true
    }
  end

  describe "com dados válidos" do
    it "retorna sucesso" do
      expect(contract.call(valid_input)).to be_success
    end

    it "description é opcional" do
      expect(contract.call(valid_input.except(:description))).to be_success
    end
  end

  describe "name" do
    it "é obrigatório" do
      result = contract.call(valid_input.merge(name: ""))
      expect(result.errors[:name]).not_to be_empty
    end
  end

  describe "price_cents" do
    it "é obrigatório" do
      result = contract.call(valid_input.except(:price_cents))
      expect(result.errors[:price_cents]).not_to be_empty
    end

    it "deve ser inteiro positivo" do
      result = contract.call(valid_input.merge(price_cents: 0))
      expect(result.errors[:price_cents]).to include("deve ser maior que zero")
    end

    it "rejeita valor negativo" do
      result = contract.call(valid_input.merge(price_cents: -100))
      expect(result.errors[:price_cents]).to include("deve ser maior que zero")
    end
  end

  describe "currency" do
    it "é obrigatório" do
      result = contract.call(valid_input.merge(currency: ""))
      expect(result.errors[:currency]).not_to be_empty
    end

    it "aceita BRL" do
      expect(contract.call(valid_input.merge(currency: "BRL"))).to be_success
    end

    it "aceita USD" do
      expect(contract.call(valid_input.merge(currency: "USD"))).to be_success
    end

    it "rejeita moeda inválida" do
      result = contract.call(valid_input.merge(currency: "EUR"))
      expect(result.errors[:currency]).to include("deve ser BRL ou USD")
    end
  end

  describe "interval_count" do
    it "é obrigatório" do
      result = contract.call(valid_input.except(:interval_count))
      expect(result.errors[:interval_count]).not_to be_empty
    end

    it "deve ser inteiro positivo" do
      result = contract.call(valid_input.merge(interval_count: 0))
      expect(result.errors[:interval_count]).to include("deve ser maior que zero")
    end
  end

  describe "interval_type" do
    it "é obrigatório" do
      result = contract.call(valid_input.merge(interval_type: ""))
      expect(result.errors[:interval_type]).not_to be_empty
    end

    it "aceita month" do
      expect(contract.call(valid_input.merge(interval_type: "month"))).to be_success
    end

    it "aceita year" do
      expect(contract.call(valid_input.merge(interval_type: "year"))).to be_success
    end

    it "rejeita tipo inválido" do
      result = contract.call(valid_input.merge(interval_type: "week"))
      expect(result.errors[:interval_type]).to include("deve ser month ou year")
    end
  end

  describe "active" do
    it "é obrigatório" do
      result = contract.call(valid_input.except(:active))
      expect(result.errors[:active]).not_to be_empty
    end

    it "aceita false" do
      expect(contract.call(valid_input.merge(active: false))).to be_success
    end
  end
end
