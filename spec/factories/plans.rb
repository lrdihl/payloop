FactoryBot.define do
  factory :plan do
    name           { Faker::Commerce.product_name }
    description    { Faker::Lorem.sentence }
    price_cents    { Faker::Number.between(from: 100, to: 99900) }
    currency       { "BRL" }
    interval_count { 1 }
    interval_type  { "month" }
    active         { true }

    trait :inactive do
      active { false }
    end

    trait :annual do
      interval_count { 12 }
      interval_type  { "month" }
    end
  end
end
