require "rails_helper"

RSpec.describe Shared::PaymentMethods::CreditCard do
  subject(:credit_card) { described_class.new }

  describe "#human_name" do
    it { expect(credit_card.human_name).to eq("Cartão de Crédito") }
  end

  describe "#process" do
    let(:payment) { build(:payment) }

    it "retorna Success" do
      result = credit_card.process(payment:)
      expect(result).to be_success
    end

    it "seta transaction_id no payment" do
      credit_card.process(payment:)
      expect(payment.transaction_id).to be_present
    end

    it "seta gateway_response no payment" do
      credit_card.process(payment:)
      expect(payment.gateway_response).to be_present
    end

    it "loga no console" do
      expect(Rails.logger).to receive(:info).with(/Cartão de Crédito/)
      credit_card.process(payment:)
    end
  end

  describe "Registry" do
    it "está registrado com a chave :credit_card" do
      expect(Shared::PaymentMethods::Registry.find(:credit_card)).to eq(described_class)
    end
  end
end
