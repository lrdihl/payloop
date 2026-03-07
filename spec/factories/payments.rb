FactoryBot.define do
  factory :payment do
    association :subscription
    amount_cents   { 9990 }
    currency       { "BRL" }
    payment_method { "credit_card" }
    status         { :pending }
    attempt_number { 1 }

    trait :succeeded do
      status         { :succeeded }
      transaction_id { SecureRandom.uuid }
    end

    trait :failed do
      status { :failed }
    end
  end
end
