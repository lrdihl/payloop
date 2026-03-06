FactoryBot.define do
  factory :subscription do
    association :user
    association :plan
    status       { :pending_payment }
    joined_at    { Date.current }
    next_due_date { Date.current }
    closed_at    { Date.current >> 12 }
  end
end
