class WebhookToken < ApplicationRecord
  # 5. Validations
  validates :token,   presence: true, uniqueness: true
  validates :webhook, presence: true

  # 10. Public Class Methods

  def self.find_for_authentication(webhook, token)
    find_by(webhook:, token:)&.used
  end

  # 12. Public Instance Methods

  def http_authentication_token
    "Token #{token}"
  end

  def used
    update(last_used_at: Time.current) if last_used_at.nil? || last_used_at < 1.minute.ago
    self
  end
end
