require "rails_helper"

RSpec.describe Shared::PaymentMethods::Base do
  subject(:base) { described_class.new }

  describe "#human_name" do
    it "levanta NotImplementedError" do
      expect { base.human_name }.to raise_error(NotImplementedError)
    end
  end

  describe "#process" do
    it "levanta NotImplementedError" do
      expect { base.process(payment: double) }.to raise_error(NotImplementedError)
    end
  end
end
