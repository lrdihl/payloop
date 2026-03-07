# spec/models/webhook_token_spec.rb
require "rails_helper"

RSpec.describe WebhookToken, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe "validações" do
    subject { build(:webhook_token) }

    it { is_expected.to validate_presence_of(:webhook) }
    it { is_expected.to validate_presence_of(:token) }
    it { is_expected.to validate_uniqueness_of(:token) }
  end

  describe ".find_for_authentication" do
    let!(:webhook_token) { create(:webhook_token, webhook: "gateway_callbacks", token: "secret123") }

    it "retorna o token quando webhook e token são válidos" do
      result = described_class.find_for_authentication("gateway_callbacks", "secret123")
      expect(result).to eq(webhook_token)
    end

    it "retorna nil quando o webhook não corresponde" do
      result = described_class.find_for_authentication("outro_webhook", "secret123")
      expect(result).to be_nil
    end

    it "retorna nil quando o token não corresponde" do
      result = described_class.find_for_authentication("gateway_callbacks", "errado")
      expect(result).to be_nil
    end

    it "atualiza last_used_at ao encontrar" do
      freeze_time do
        described_class.find_for_authentication("gateway_callbacks", "secret123")
        expect(webhook_token.reload.last_used_at).to be_within(1.second).of(Time.current)
      end
    end

    it "não atualiza last_used_at se usado há menos de 1 minuto" do
      travel_to 30.seconds.ago do
        webhook_token.update!(last_used_at: Time.current)
      end
      original_time = webhook_token.reload.last_used_at

      described_class.find_for_authentication("gateway_callbacks", "secret123")
      expect(webhook_token.reload.last_used_at).to eq(original_time)
    end
  end

  describe "#http_authentication_token" do
    let(:webhook_token) { build(:webhook_token, token: "abc123") }

    it "retorna string no formato 'Token <token>'" do
      expect(webhook_token.http_authentication_token).to eq("Token abc123")
    end
  end
end
