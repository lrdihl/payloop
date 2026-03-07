# spec/domains/billing/jobs/charge_subscriptions_job_spec.rb
require "rails_helper"

RSpec.describe Billing::Jobs::ChargeSubscriptionsJob, type: :job do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  subject(:job) { described_class.new }

  describe "#perform" do
    let(:today) { Date.new(2026, 3, 7) }

    let!(:due_active)       { create(:subscription, :active, next_due_date: today) }
    let!(:due_lifetime)     { create(:subscription, :active, next_due_date: today, closed_at: nil) }
    let!(:not_due_active)   { create(:subscription, :active, next_due_date: today + 1.day) }
    let!(:due_pending)      { create(:subscription,          next_due_date: today) } # pending_payment — ignora
    let!(:due_error)        { create(:subscription, :error_payment, next_due_date: today) } # error_payment — ignora

    before { travel_to today }
    after  { travel_back }

    it "move para pending_payment subscriptions active com next_due_date == hoje" do
      job.perform
      expect(due_active.reload.status).to eq("pending_payment")
    end

    it "move para pending_payment subscriptions lifetime com next_due_date == hoje" do
      job.perform
      expect(due_lifetime.reload.status).to eq("pending_payment")
    end

    it "não altera subscriptions active com next_due_date futuro" do
      job.perform
      expect(not_due_active.reload.status).to eq("active")
    end

    it "não altera subscriptions já em pending_payment" do
      job.perform
      expect(due_pending.reload.status).to eq("pending_payment")
    end

    it "não altera subscriptions em error_payment" do
      job.perform
      expect(due_error.reload.status).to eq("error_payment")
    end

    it "enfileira BillingJob para cada subscription cobrada" do
      expect {
        job.perform
      }.to have_enqueued_job(Billing::Jobs::BillingJob).exactly(2).times
    end
  end
end
