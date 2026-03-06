FactoryBot.define do
  factory :plan do
    name           { Faker::Commerce.product_name }
    description    { Faker::Lorem.sentence }
    price_cents    { Faker::Number.between(from: 100, to: 99900) }
    currency       { "BRL" }
    interval_count { 1 }
    interval_type  { "month" }
    active         { true }
    duration_count { 12 }
    duration_type  { "month" }
    renewable      { false }

    trait :inactive do
      active { false }
    end

    trait :annual do
      interval_count { 12 }
      interval_type  { "month" }
    end

    trait :lifetime do
      duration_count { nil }
      duration_type  { nil }
    end

    trait :renewable do
      renewable { true }
    end
  end
end
