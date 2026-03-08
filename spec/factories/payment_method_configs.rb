FactoryBot.define do
  factory :payment_method_config do
    key     { "credit_card" }
    enabled { true }

    trait :boleto       do key { "boleto" } end
    trait :bank_deposit do key { "bank_deposit" } end
    trait :disabled     do enabled { false } end
  end
end
