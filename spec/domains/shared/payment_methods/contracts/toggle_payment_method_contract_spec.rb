require "rails_helper"

RSpec.describe Shared::PaymentMethods::Contracts::TogglePaymentMethodContract do
  subject(:contract) { described_class.new }

  describe "com dados válidos" do
    it "aceita credit_card com enabled: true" do
      result = contract.call(key: "credit_card", enabled: true)
      expect(result).to be_success
    end

    it "aceita boleto com enabled: false" do
      result = contract.call(key: "boleto", enabled: false)
      expect(result).to be_success
    end

    it "aceita bank_deposit" do
      result = contract.call(key: "bank_deposit", enabled: true)
      expect(result).to be_success
    end
  end

  describe "key" do
    it "é obrigatória" do
      result = contract.call(enabled: true)
      expect(result.errors[:key]).not_to be_empty
    end

    it "rejeita key inválida" do
      result = contract.call(key: "pix", enabled: true)
      expect(result.errors[:key]).not_to be_empty
    end

    it "rejeita manual" do
      result = contract.call(key: "manual", enabled: false)
      expect(result.errors[:key]).not_to be_empty
    end

    it "rejeita string vazia" do
      result = contract.call(key: "", enabled: true)
      expect(result.errors[:key]).not_to be_empty
    end
  end

  describe "enabled" do
    it "é obrigatório" do
      result = contract.call(key: "credit_card")
      expect(result.errors[:enabled]).not_to be_empty
    end

    it "rejeita string no lugar de boolean" do
      result = contract.call(key: "credit_card", enabled: "sim")
      expect(result.errors[:enabled]).not_to be_empty
    end
  end
end
