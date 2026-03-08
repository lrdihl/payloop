FactoryBot.define do
  factory :plan do
    sequence(:name) { |n| "Plano #{n}" }
    description    { "Descrição do plano" }
    price_cents    { 4990 }
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
