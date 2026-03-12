# spec/models/payment_lock_spec.rb
require "rails_helper"

RSpec.describe Payment, "optimistic locking", type: :model do
  let!(:payment) { create(:payment) }

  it "possui lock_version com valor inicial 0" do
    expect(payment.lock_version).to eq(0)
  end

  it "incrementa lock_version a cada update" do
    payment.update!(status: :succeeded)
    expect(payment.reload.lock_version).to eq(1)
  end

  it "levanta ActiveRecord::StaleObjectError quando versão está desatualizada" do
    stale = Payment.find(payment.id)
    payment.update!(status: :succeeded)

    expect {
      stale.update!(status: :failed)
    }.to raise_error(ActiveRecord::StaleObjectError)
  end
end
