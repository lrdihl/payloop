# spec/domains/subscriptions/contracts/update_payment_method_contract_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Contracts::UpdatePaymentMethodContract do
  subject(:contract) { described_class.new }

  let(:valid_keys) { Shared::PaymentMethods::Registry.active_methods.keys.map(&:to_s) }
  let(:valid_input) { { payment_method: valid_keys.first } }

  describe "com dados válidos" do
    it "retorna sucesso para cada método ativo" do
      valid_keys.each do |key|
        result = contract.call(payment_method: key)
        expect(result).to be_success, "esperava sucesso para '#{key}'"
      end
    end
  end

  describe "payment_method" do
    it "é obrigatório" do
      result = contract.call({})
      expect(result.errors[:payment_method]).not_to be_empty
    end

    it "rejeita método desconhecido" do
      result = contract.call(payment_method: "xpto")
      expect(result.errors[:payment_method]).not_to be_empty
    end

    it "rejeita método inativo" do
      inactive_key = valid_keys.first.to_sym
      Shared::PaymentMethods::Registry.disable(inactive_key)

      result = contract.call(payment_method: inactive_key.to_s)
      expect(result.errors[:payment_method]).not_to be_empty
    ensure
      Shared::PaymentMethods::Registry.enable(inactive_key)
    end

    it "rejeita string vazia" do
      result = contract.call(payment_method: "")
      expect(result.errors[:payment_method]).not_to be_empty
    end
  end
end
