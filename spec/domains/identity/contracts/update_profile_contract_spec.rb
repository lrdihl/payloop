# spec/domains/identity/contracts/update_profile_contract_spec.rb
require "rails_helper"

RSpec.describe Identity::Contracts::UpdateProfileContract do
  subject(:contract) { described_class.new }

  let(:valid_input) do
    {
      full_name: "João da Silva",
      document:  "12345678901",
      phone:     "47999999999"
    }
  end

  describe "com dados válidos" do
    it "retorna sucesso" do
      expect(contract.call(valid_input)).to be_success
    end
  end

  describe "full_name" do
    it "é obrigatório" do
      result = contract.call(valid_input.merge(full_name: ""))
      expect(result.errors[:full_name]).not_to be_empty
    end

    it "deve ter no mínimo 3 caracteres" do
      result = contract.call(valid_input.merge(full_name: "AB"))
      expect(result.errors[:full_name]).to include("deve ter no mínimo 3 caracteres")
    end
  end

  describe "document" do
    it "aceita CPF com 11 dígitos" do
      result = contract.call(valid_input.merge(document: "12345678901"))
      expect(result).to be_success
    end

    it "aceita CNPJ com 14 dígitos" do
      result = contract.call(valid_input.merge(document: "12345678000199"))
      expect(result).to be_success
    end

    it "rejeita documento com tamanho inválido" do
      result = contract.call(valid_input.merge(document: "1234"))
      expect(result.errors[:document]).to include("deve ser um CPF (11 dígitos) ou CNPJ (14 dígitos)")
    end

    it "é obrigatório" do
      result = contract.call(valid_input.merge(document: ""))
      expect(result.errors[:document]).not_to be_empty
    end
  end

  describe "phone" do
    it "é opcional" do
      result = contract.call(valid_input.except(:phone))
      expect(result).to be_success
    end

    it "aceita nil" do
      result = contract.call(valid_input.merge(phone: nil))
      expect(result).to be_success
    end
  end
end
