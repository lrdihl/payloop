require "rails_helper"

RSpec.describe Shared::PaymentMethods::BankDeposit do
  subject(:bank_deposit) { described_class.new }

  describe "#human_name" do
    it { expect(bank_deposit.human_name).to eq("Depósito Bancário") }
  end

  describe "#process" do
    let(:payment) { build(:payment) }

    it "retorna Success" do
      result = bank_deposit.process(payment:)
      expect(result).to be_success
    end

    it "seta transaction_id no payment" do
      bank_deposit.process(payment:)
      expect(payment.transaction_id).to be_present
    end

    it "seta gateway_response no payment" do
      bank_deposit.process(payment:)
      expect(payment.gateway_response).to be_present
    end

    it "loga no console" do
      expect(Rails.logger).to receive(:info).with(/Depósito Bancário/)
      bank_deposit.process(payment:)
    end
  end

  describe "Registry" do
    it "está registrado com a chave :bank_deposit" do
      expect(Shared::PaymentMethods::Registry.find(:bank_deposit)).to eq(described_class)
    end
  end
end
