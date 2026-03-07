require "rails_helper"

RSpec.describe Shared::PaymentMethods::Boleto do
  subject(:boleto) { described_class.new }

  describe "#human_name" do
    it { expect(boleto.human_name).to eq("Boleto Bancário") }
  end

  describe "#process" do
    let(:payment) { build(:payment) }

    it "retorna Success" do
      result = boleto.process(payment:)
      expect(result).to be_success
    end

    it "seta transaction_id no payment" do
      boleto.process(payment:)
      expect(payment.transaction_id).to be_present
    end

    it "seta gateway_response no payment" do
      boleto.process(payment:)
      expect(payment.gateway_response).to be_present
    end

    it "loga no console" do
      expect(Rails.logger).to receive(:info).with(/Boleto/)
      boleto.process(payment:)
    end
  end

  describe "Registry" do
    it "está registrado com a chave :boleto" do
      expect(Shared::PaymentMethods::Registry.find(:boleto)).to eq(described_class)
    end
  end
end
