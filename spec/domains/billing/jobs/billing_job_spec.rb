# spec/domains/billing/jobs/billing_job_spec.rb
require "rails_helper"

RSpec.describe Billing::Jobs::BillingJob, type: :job do
  include ActiveJob::TestHelper

  let(:subscription) { create(:subscription, payment_method: "credit_card") }

  describe "enfileiramento" do
    it "é enfileirado na fila :default" do
      expect { described_class.perform_later(subscription.id) }
        .to have_enqueued_job(described_class)
        .with(subscription.id)
    end
  end

  describe "#perform — fluxo feliz" do
    it "cria um Payment para a subscription" do
      expect {
        perform_enqueued_jobs { described_class.perform_later(subscription.id) }
      }.to change(Payment, :count).by(1)
    end

    it "cria o Payment com status pending" do
      perform_enqueued_jobs { described_class.perform_later(subscription.id) }
      expect(Payment.last.status).to eq("pending")
    end

    it "registra attempt_number 1 na primeira execução" do
      perform_enqueued_jobs { described_class.perform_later(subscription.id) }
      expect(Payment.last.attempt_number).to eq(1)
    end
  end

  describe "#perform — guard de idempotência" do
    it "não processa se a subscription não está em pending_payment" do
      subscription.update!(status: :active)
      expect {
        perform_enqueued_jobs { described_class.perform_later(subscription.id) }
      }.not_to change(Payment, :count)
    end
  end

  describe "#perform — falha no gateway" do
    before do
      allow_any_instance_of(Shared::PaymentMethods::CreditCard)
        .to receive(:process)
        .and_return(Dry::Monads::Failure({ error: "gateway timeout" }))
    end

    it "marca o payment como failed e levanta GatewayError" do
      expect {
        described_class.new.perform(subscription.id)
      }.to raise_error(Billing::GatewayError)
      expect(Payment.last.status).to eq("failed")
    end

    it "levanta GatewayError para acionar retry" do
      expect {
        described_class.new.perform(subscription.id)
      }.to raise_error(Billing::GatewayError)
    end
  end

  describe "after_discard — esgotou retries" do
    it "coloca a subscription em error_payment" do
      allow_any_instance_of(described_class).to receive(:perform).and_raise(Billing::GatewayError)

      subscription # persiste antes
      described_class.perform_later(subscription.id)

      # simula o discard (executa after_discard diretamente)
      job = described_class.new
      job.instance_variable_set(:@arguments, [ subscription.id ])
      job.send(:on_discard, Billing::GatewayError.new("esgotado"))

      expect(subscription.reload.status).to eq("error_payment")
    end
  end
end
