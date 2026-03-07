class WebhookToken < ApplicationRecord
  validates :webhook, presence: true
  validates :token,   presence: true, uniqueness: true

  def self.find_for_authentication(webhook, token)
    find_by(webhook:, token:)&.used
  end

  def used
    update(last_used_at: Time.current) if last_used_at.nil? || last_used_at < 1.minute.ago
    self
  end

  def http_authentication_token
    "Token #{token}"
  end
end
