# spec/domains/subscriptions/contracts/create_subscription_contract_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Contracts::CreateSubscriptionContract do
  subject(:contract) { described_class.new }

  let(:valid_input) do
    {
      user_id:   1,
      plan_id:   1,
      joined_at: Date.current
    }
  end

  describe "com dados válidos" do
    it "retorna sucesso" do
      expect(contract.call(valid_input)).to be_success
    end
  end

  describe "user_id" do
    it "é obrigatório" do
      result = contract.call(valid_input.except(:user_id))
      expect(result.errors[:user_id]).not_to be_empty
    end

    it "deve ser inteiro" do
      result = contract.call(valid_input.merge(user_id: "abc"))
      expect(result.errors[:user_id]).not_to be_empty
    end
  end

  describe "plan_id" do
    it "é obrigatório" do
      result = contract.call(valid_input.except(:plan_id))
      expect(result.errors[:plan_id]).not_to be_empty
    end

    it "deve ser inteiro" do
      result = contract.call(valid_input.merge(plan_id: "abc"))
      expect(result.errors[:plan_id]).not_to be_empty
    end
  end

  describe "joined_at" do
    it "é obrigatório" do
      result = contract.call(valid_input.except(:joined_at))
      expect(result.errors[:joined_at]).not_to be_empty
    end

    it "deve ser uma data válida" do
      result = contract.call(valid_input.merge(joined_at: "nao-e-data"))
      expect(result.errors[:joined_at]).not_to be_empty
    end
  end
end
