# spec/models/payment_spec.rb
require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "associações" do
    it { is_expected.to belong_to(:subscription) }
  end

  describe "validações" do
    subject do
      build(:payment)
    end

    it { is_expected.to validate_presence_of(:amount_cents) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:payment_method) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:attempt_number) }

    it "rejeita amount_cents zero ou negativo" do
      subject.amount_cents = 0
      expect(subject).not_to be_valid
    end

    it "rejeita attempt_number zero ou negativo" do
      subject.attempt_number = 0
      expect(subject).not_to be_valid
    end
  end

  describe "enum status" do
    it "define os 3 valores esperados" do
      expect(described_class.statuses.keys).to match_array(%w[pending succeeded failed])
    end

    it "default é pending" do
      expect(described_class.new.status).to eq("pending")
    end
  end

  describe "campos opcionais" do
    subject { build(:payment) }

    it "aceita transaction_id nil" do
      subject.transaction_id = nil
      expect(subject).to be_valid
    end

    it "aceita gateway_response nil" do
      subject.gateway_response = nil
      expect(subject).to be_valid
    end
  end
end
