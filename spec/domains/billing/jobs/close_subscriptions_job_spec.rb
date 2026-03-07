# spec/domains/billing/jobs/close_subscriptions_job_spec.rb
require "rails_helper"

RSpec.describe Billing::Jobs::CloseSubscriptionsJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  subject(:job) { described_class.new }

  describe "#perform" do
    let(:today) { Date.new(2026, 3, 7) }

    let!(:due_active)         { create(:subscription, :active,   closed_at: today) }
    let!(:due_pending)        { create(:subscription,            closed_at: today) }         # pending_payment — ignora
    let!(:due_error)          { create(:subscription, :error_payment, closed_at: today) }    # error_payment — ignora
    let!(:not_due_active)     { create(:subscription, :active,   closed_at: today + 1.day) } # amanhã — ignora
    let!(:no_closed_lifetime) { create(:subscription, :active,   closed_at: nil) }           # lifetime — ignora

    before { travel_to today }
    after  { travel_back }

    it "fecha subscriptions active com closed_at == hoje" do
      job.perform
      expect(due_active.reload.status).to eq("closed")
    end

    it "não altera subscriptions pending_payment com closed_at == hoje" do
      job.perform
      expect(due_pending.reload.status).to eq("pending_payment")
    end

    it "não altera subscriptions error_payment com closed_at == hoje" do
      job.perform
      expect(due_error.reload.status).to eq("error_payment")
    end

    it "não altera subscriptions active com closed_at futuro" do
      job.perform
      expect(not_due_active.reload.status).to eq("active")
    end

    it "não altera subscriptions lifetime (closed_at nil)" do
      job.perform
      expect(no_closed_lifetime.reload.status).to eq("active")
    end

    it "fecha exatamente as subscriptions elegíveis" do
      job.perform
      expect(Subscription.closed).to contain_exactly(due_active)
    end
  end
end
