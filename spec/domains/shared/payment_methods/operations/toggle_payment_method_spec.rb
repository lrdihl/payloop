require "rails_helper"

RSpec.describe Shared::PaymentMethods::Operations::TogglePaymentMethod do
  subject(:operation) { described_class.new }

  # Garante que o Registry está com estado padrão (todos ativos) antes de cada teste
  around do |example|
    example.run
  ensure
    Shared::PaymentMethods::Registry.enable(:credit_card)
    Shared::PaymentMethods::Registry.enable(:boleto)
    Shared::PaymentMethods::Registry.enable(:bank_deposit)
  end

  describe "desativar um método" do
    let!(:config) { create(:payment_method_config, key: "credit_card", enabled: true) }

    it "retorna Success com o config atualizado" do
      result = operation.call(key: "credit_card", enabled: false)
      expect(result).to be_success
      expect(result.value!).to be_a(PaymentMethodConfig)
    end

    it "persiste enabled: false no banco" do
      operation.call(key: "credit_card", enabled: false)
      expect(config.reload.enabled).to be false
    end

    it "desativa o método no Registry" do
      operation.call(key: "credit_card", enabled: false)
      expect(Shared::PaymentMethods::Registry.active?(:credit_card)).to be false
    end
  end

  describe "ativar um método" do
    let!(:config) { create(:payment_method_config, key: "boleto", enabled: false) }

    before { Shared::PaymentMethods::Registry.disable(:boleto) }

    it "retorna Success com o config atualizado" do
      result = operation.call(key: "boleto", enabled: true)
      expect(result).to be_success
    end

    it "persiste enabled: true no banco" do
      operation.call(key: "boleto", enabled: true)
      expect(config.reload.enabled).to be true
    end

    it "ativa o método no Registry" do
      operation.call(key: "boleto", enabled: true)
      expect(Shared::PaymentMethods::Registry.active?(:boleto)).to be true
    end
  end

  describe "com dados inválidos" do
    it "retorna Failure com tipo :validation para key inválida" do
      result = operation.call(key: "pix", enabled: true)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
      expect(result.failure[:errors][:key]).not_to be_empty
    end

    it "retorna Failure com tipo :validation quando enabled está ausente" do
      result = operation.call(key: "credit_card")
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
    end

    it "não altera o Registry em caso de falha de validação" do
      operation.call(key: "pix", enabled: false)
      expect(Shared::PaymentMethods::Registry.active?(:credit_card)).to be true
    end
  end
end
