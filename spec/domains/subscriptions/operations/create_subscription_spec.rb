# spec/domains/subscriptions/operations/create_subscription_spec.rb
require "rails_helper"

RSpec.describe Subscriptions::Operations::CreateSubscription do
  subject(:operation) { described_class.new }

  let(:user) { create(:user) }
  let(:plan) { create(:plan, duration_count: 12, duration_type: "month") }

  let(:valid_params) do
    {
      user_id:   user.id,
      plan_id:   plan.id,
      joined_at: Date.current
    }
  end

  # ─── Fluxo feliz ────────────────────────────────────────────────────────────

  describe "com dados válidos" do
    it "retorna Success com a subscription criada" do
      result = operation.call(valid_params)
      expect(result).to be_success
      expect(result.value!).to be_a(Subscription)
    end

    it "cria a subscription com status pending_payment" do
      result = operation.call(valid_params)
      expect(result.value!.status).to eq("pending_payment")
    end

    it "define next_due_date igual a joined_at" do
      result = operation.call(valid_params)
      expect(result.value!.next_due_date).to eq(Date.current)
    end

    it "calcula closed_at como joined_at + duration do plano" do
      result    = operation.call(valid_params)
      expected  = Date.current >> 12
      expect(result.value!.closed_at).to eq(expected)
    end

    it "define closed_at como nil quando o plano é vitalício" do
      lifetime_plan = create(:plan, :lifetime)
      result = operation.call(valid_params.merge(plan_id: lifetime_plan.id))
      expect(result.value!.closed_at).to be_nil
    end
  end

  # ─── Falha no step :validate ────────────────────────────────────────────────

  describe "com dados inválidos" do
    it "retorna Failure com tipo :validation quando user_id está ausente" do
      result = operation.call(valid_params.except(:user_id))
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
      expect(result.failure[:errors][:user_id]).not_to be_empty
    end

    it "retorna Failure com tipo :validation quando joined_at está ausente" do
      result = operation.call(valid_params.except(:joined_at))
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
      expect(result.failure[:errors][:joined_at]).not_to be_empty
    end

    it "não cria subscription quando a validação falha" do
      expect { operation.call(valid_params.except(:user_id)) }.not_to change(Subscription, :count)
    end
  end

  # ─── Falha no step :check_no_active ────────────────────────────────────────

  describe "quando o usuário já tem assinatura ativa no mesmo plano" do
    before { create(:subscription, :active, user:, plan:) }

    it "retorna Failure com tipo :conflict" do
      result = operation.call(valid_params)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:conflict)
    end

    it "não cria nova subscription" do
      expect { operation.call(valid_params) }.not_to change(Subscription, :count)
    end
  end

  describe "quando o usuário já tem assinatura pending_payment no mesmo plano" do
    before { create(:subscription, user:, plan:) }

    it "retorna Failure com tipo :conflict" do
      result = operation.call(valid_params)
      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:conflict)
    end
  end

  describe "quando existe apenas assinatura em estado terminal no mesmo plano" do
    it "permite criar nova assinatura quando existe canceled" do
      create(:subscription, :canceled, user:, plan:)
      result = operation.call(valid_params)
      expect(result).to be_success
    end

    it "permite criar nova assinatura quando existe closed" do
      create(:subscription, :closed, user:, plan:)
      result = operation.call(valid_params)
      expect(result).to be_success
    end

    it "permite criar nova assinatura quando existe error_payment" do
      create(:subscription, :error_payment, user:, plan:)
      result = operation.call(valid_params)
      expect(result).to be_success
    end
  end
end
