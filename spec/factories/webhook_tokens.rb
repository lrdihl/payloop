FactoryBot.define do
  factory :webhook_token do
    webhook { "gateway_callbacks" }
    token   { SecureRandom.hex(32) }
  end
end
