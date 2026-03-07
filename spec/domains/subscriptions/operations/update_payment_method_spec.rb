# spec/domains/subscriptions/operations/update_payment_method_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Operations::UpdatePaymentMethod do
  subject(:operation) { described_class.new }

  let(:subscription) { create(:subscription, payment_method: "credit_card") }

  describe "com dados válidos" do
    it "retorna Success com a subscription atualizada" do
      result = operation.call(subscription, { payment_method: "boleto" })
      expect(result).to be_success
      expect(result.value!).to be_a(Subscription)
    end

    it "persiste o novo payment_method" do
      operation.call(subscription, { payment_method: "boleto" })
      expect(subscription.reload.payment_method).to eq("boleto")
    end

    it "aceita qualquer método ativo do Registry" do
      Shared::PaymentMethods::Registry.active_methods.keys.each do |key|
        result = operation.call(subscription, { payment_method: key.to_s })
        expect(result).to be_success, "esperava sucesso para '#{key}'"
      end
    end
  end

  describe "com dados inválidos" do
    it "retorna Failure quando payment_method é desconhecido" do
      result = operation.call(subscription, { payment_method: "xpto" })
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
    end

    it "retorna Failure quando payment_method está ausente" do
      result = operation.call(subscription, {})
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
    end

    it "retorna Failure quando método está inativo" do
      Shared::PaymentMethods::Registry.disable(:boleto)
      result = operation.call(subscription, { payment_method: "boleto" })
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
    ensure
      Shared::PaymentMethods::Registry.enable(:boleto)
    end

    it "não altera o payment_method em caso de falha" do
      operation.call(subscription, { payment_method: "xpto" })
      expect(subscription.reload.payment_method).to eq("credit_card")
    end
  end
end
