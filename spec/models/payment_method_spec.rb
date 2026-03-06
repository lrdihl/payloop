require "rails_helper"

RSpec.describe PaymentMethod, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:type) }
  end

  describe "interface base" do
    subject(:pm) { described_class.new }

    it "#human_name levanta NotImplementedError" do
      expect { pm.human_name }.to raise_error(NotImplementedError)
    end

    it "#simulate levanta NotImplementedError" do
      expect { pm.simulate(money: Shared::Values::Money.new(cents: 100, currency: "BRL")) }.to raise_error(NotImplementedError)
    end

    it "#process levanta NotImplementedError" do
      expect { pm.process(money: Shared::Values::Money.new(cents: 100, currency: "BRL")) }.to raise_error(NotImplementedError)
    end
  end
end
