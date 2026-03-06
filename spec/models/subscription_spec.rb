# spec/models/subscription_spec.rb
require "rails_helper"

RSpec.describe Subscription, type: :model do
  describe "associações" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:plan) }
  end

  describe "validações" do
    subject do
      described_class.new(
        user: build(:user),
        plan: build(:plan),
        joined_at: Date.current,
        next_due_date: Date.current,
        status: :pending_payment
      )
    end

    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:plan) }
    it { is_expected.to validate_presence_of(:joined_at) }
    it { is_expected.to validate_presence_of(:next_due_date) }
  end

  describe "enum status" do
    it "define os 5 valores esperados" do
      expect(described_class.statuses.keys).to match_array(
        %w[pending_payment active error_payment canceled closed]
      )
    end

    it "default é pending_payment" do
      expect(described_class.new.status).to eq("pending_payment")
    end
  end

  describe "VALID_TRANSITIONS" do
    subject(:transitions) { described_class::VALID_TRANSITIONS }

    it "pending_payment pode ir para active e error_payment" do
      expect(transitions["pending_payment"]).to match_array(%w[active error_payment])
    end

    it "error_payment pode ir para pending_payment e canceled" do
      expect(transitions["error_payment"]).to match_array(%w[pending_payment canceled])
    end

    it "active pode ir para canceled e closed" do
      expect(transitions["active"]).to match_array(%w[canceled closed])
    end

    it "canceled não pode transitar para nenhum estado" do
      expect(transitions["canceled"]).to be_empty
    end

    it "closed não pode transitar para nenhum estado" do
      expect(transitions["closed"]).to be_empty
    end
  end

  describe "#valid_transition?" do
    let(:subscription) { described_class.new(status: :pending_payment) }

    it "retorna true para transição válida" do
      expect(subscription.valid_transition?("active")).to be true
    end

    it "retorna true para outra transição válida" do
      expect(subscription.valid_transition?("error_payment")).to be true
    end

    it "retorna false para transição inválida" do
      expect(subscription.valid_transition?("closed")).to be false
    end

    it "retorna false para o próprio status" do
      expect(subscription.valid_transition?("pending_payment")).to be false
    end

    context "quando status é canceled" do
      let(:subscription) { described_class.new(status: :canceled) }

      it "retorna false para qualquer transição" do
        expect(subscription.valid_transition?("active")).to be false
        expect(subscription.valid_transition?("closed")).to be false
      end
    end
  end

  describe "escopos" do
    let!(:sub_pending)  { create(:subscription, status: :pending_payment) }
    let!(:sub_active)   { create(:subscription, status: :active) }
    let!(:sub_error)    { create(:subscription, status: :error_payment) }
    let!(:sub_canceled) { create(:subscription, status: :canceled) }
    let!(:sub_closed)   { create(:subscription, status: :closed) }

    describe ".pending_payment" do
      it { expect(described_class.pending_payment).to contain_exactly(sub_pending) }
    end

    describe ".active" do
      it { expect(described_class.active).to contain_exactly(sub_active) }
    end

    describe ".error_payment" do
      it { expect(described_class.error_payment).to contain_exactly(sub_error) }
    end

    describe ".canceled" do
      it { expect(described_class.canceled).to contain_exactly(sub_canceled) }
    end

    describe ".closed" do
      it { expect(described_class.closed).to contain_exactly(sub_closed) }
    end

    describe ".current" do
      it "retorna active e pending_payment" do
        expect(described_class.current).to contain_exactly(sub_pending, sub_active)
      end

      it "não retorna error_payment, canceled nem closed" do
        expect(described_class.current).not_to include(sub_error, sub_canceled, sub_closed)
      end
    end
  end

  describe "#residual_value" do
    context "quando a assinatura tem data de encerramento" do
      let(:joined_at)  { Date.new(2026, 1, 1) }
      let(:closed_at)  { Date.new(2026, 1, 31) }
      let(:plan)       { build(:plan, price_cents: 3000) }
      let(:subscription) do
        described_class.new(
          plan:,
          joined_at:,
          closed_at:,
          status: :active,
          next_due_date: joined_at
        )
      end

      it "retorna valor proporcional aos dias restantes" do
        travel_to Date.new(2026, 1, 16) do
          days_remaining = (closed_at - Date.current).to_i
          days_period    = (closed_at - joined_at).to_i
          expected       = (plan.price_cents * days_remaining.to_f / days_period).round

          expect(subscription.residual_value).to eq(expected)
        end
      end

      it "retorna 0 quando Date.current >= closed_at" do
        travel_to closed_at do
          expect(subscription.residual_value).to eq(0)
        end
      end
    end

    context "quando a assinatura é vitalícia (closed_at nil)" do
      let(:subscription) do
        described_class.new(
          plan: build(:plan),
          joined_at: Date.current,
          closed_at: nil,
          status: :active,
          next_due_date: Date.current
        )
      end

      it "retorna nil" do
        expect(subscription.residual_value).to be_nil
      end
    end
  end
end
