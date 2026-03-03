require "rails_helper"

RSpec.describe Identity::Contracts::RegisterContract do
  subject(:contract) { described_class.new }

  let(:valid_input) do
    {
      email:                 "usuario@exemplo.com",
      password:              "senha@123",
      password_confirmation: "senha@123",
      full_name:             "João da Silva",
      document:              "12345678901",
      phone:                 "47999999999"
    }
  end

  describe "com dados válidos" do
    it "retorna sucesso" do
      expect(contract.call(valid_input)).to be_success
    end
  end

  describe "email" do
    it "é obrigatório" do
      result = contract.call(valid_input.merge(email: ""))
      expect(result.errors[:email]).not_to be_empty
    end

    it "deve ter formato válido" do
      result = contract.call(valid_input.merge(email: "nao-é-email"))
      expect(result.errors[:email]).to include("deve ser um e-mail válido")
    end
  end

  describe "password" do
    it "deve ter no mínimo 8 caracteres" do
      result = contract.call(valid_input.merge(password: "curta", password_confirmation: "curta"))
      expect(result.errors[:password]).to include("deve ter no mínimo 8 caracteres")
    end
  end

  describe "password_confirmation" do
    it "deve conferir com a senha" do
      result = contract.call(valid_input.merge(password_confirmation: "outra_senha"))
      expect(result.errors[:password_confirmation]).to include("não confere com a senha")
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
  end

  describe "phone" do
    it "é opcional" do
      result = contract.call(valid_input.except(:phone))
      expect(result).to be_success
    end
  end
end
