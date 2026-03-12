# spec/models/subscription_lock_spec.rb
require "rails_helper"

RSpec.describe Subscription, "optimistic locking", type: :model do
  let!(:subscription) { create(:subscription) }

  it "possui lock_version com valor inicial 0" do
    expect(subscription.lock_version).to eq(0)
  end

  it "incrementa lock_version a cada update" do
    subscription.update!(status: :active)
    expect(subscription.reload.lock_version).to eq(1)
  end

  it "levanta ActiveRecord::StaleObjectError quando versão está desatualizada" do
    stale = Subscription.find(subscription.id)
    subscription.update!(status: :active)

    expect {
      stale.update!(status: :error_payment)
    }.to raise_error(ActiveRecord::StaleObjectError)
  end

  it "mantém o valor original quando update concorrente falha" do
    stale = Subscription.find(subscription.id)
    subscription.update!(status: :active)

    begin
      stale.update!(status: :error_payment)
    rescue ActiveRecord::StaleObjectError
      # esperado
    end

    expect(subscription.reload.status).to eq("active")
  end
end
