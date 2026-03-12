# spec/domains/subscriptions/operations/create_subscription_concurrency_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Operations::CreateSubscription, "controle de concorrência" do
  subject(:operation) { described_class.new }

  let(:user) { create(:user) }
  let(:plan) { create(:plan, duration_count: 12, duration_type: "month") }

  let(:valid_params) do
    {
      user_id:        user.id,
      plan_id:        plan.id,
      joined_at:      Date.current,
      payment_method: "credit_card"
    }
  end

  describe "check_no_active com lock pessimista" do
    it "usa lock ao verificar assinaturas existentes" do
      # Verifica que a query de check usa lock
      relation = instance_double(ActiveRecord::Relation, exists?: false)
      allow(Subscription).to receive(:current).and_return(relation)
      allow(relation).to receive(:lock).and_return(relation)
      allow(relation).to receive(:exists?).and_return(false)

      operation.call(valid_params)

      expect(relation).to have_received(:lock)
    end
  end
end
