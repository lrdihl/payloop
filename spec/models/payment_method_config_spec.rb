require "rails_helper"

RSpec.describe PaymentMethodConfig, type: :model do
  describe "validações" do
    subject { build(:payment_method_config) }

    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_uniqueness_of(:key) }

    it "aceita keys válidas" do
      PaymentMethodConfig::SELECTABLE_KEYS.each do |key|
        expect(build(:payment_method_config, key: key)).to be_valid
      end
    end

    it "rejeita key inválida" do
      expect(build(:payment_method_config, key: "pix")).not_to be_valid
    end

    it "rejeita key manual" do
      expect(build(:payment_method_config, key: "manual")).not_to be_valid
    end

    it { is_expected.to validate_inclusion_of(:enabled).in_array([true, false]) }
  end

  describe "SELECTABLE_KEYS" do
    it "contém credit_card, boleto e bank_deposit" do
      expect(PaymentMethodConfig::SELECTABLE_KEYS).to contain_exactly("credit_card", "boleto", "bank_deposit")
    end
  end
end
