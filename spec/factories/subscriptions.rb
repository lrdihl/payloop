FactoryBot.define do
  factory :subscription do
    association :user
    association :plan
    status          { :pending_payment }
    payment_method  { "credit_card" }
    joined_at       { Date.current }
    next_due_date   { Date.current }
    closed_at do
      plan_instance = plan || association(:plan)
      if plan_instance.duration_count && plan_instance.duration_type
        Shared::Values::Period
          .new(count: plan_instance.duration_count, type: plan_instance.duration_type)
          .advance_from(joined_at)
      end
    end

    trait :active do
      status { :active }
    end

    trait :error_payment do
      status { :error_payment }
    end

    trait :canceled do
      status      { :canceled }
      canceled_at { Date.current }
    end

    trait :closed do
      status    { :closed }
      closed_at { Date.current - 1.day }
    end

    trait :lifetime do
      association :plan, factory: %i[plan lifetime]
      closed_at { nil }
    end

    trait :with_payment_method do
      transient do
        method_key { "credit_card" }
      end
      payment_method { method_key }
    end
  end
end
