require "rails_helper"

RSpec.describe Shared::PaymentMethods::Base do
  subject(:base) { described_class.new }

  describe "#human_name" do
    it "retorna tradução i18n baseada no nome da classe" do
      expect(base.human_name).to eq(I18n.t("shared.payment_methods.base"))
    end
  end

  describe "#process" do
    it "levanta NotImplementedError" do
      expect { base.process(payment: double) }.to raise_error(NotImplementedError)
    end
  end
end
