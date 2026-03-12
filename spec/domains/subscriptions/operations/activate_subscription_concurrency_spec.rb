# spec/domains/subscriptions/operations/activate_subscription_concurrency_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Operations::ActivateSubscription, "controle de concorrência" do
  subject(:operation) { described_class.new }

  let(:subscription) { create(:subscription) }

  describe "quando ocorre StaleObjectError na transição" do
    it "retorna Failure com tipo :stale ao invés de estourar exceção" do
      # Simula update concorrente: incrementa lock_version diretamente no banco
      Subscription.where(id: subscription.id).update_all(lock_version: subscription.lock_version + 1)

      result = operation.call(subscription)

      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:stale)
    end
  end
end
