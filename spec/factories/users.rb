FactoryBot.define do
  sequence(:user_email) { |n| "user#{n}@example.com" }

  factory :user do
    email    { generate(:user_email) }
    password { "senha@123" }
    password_confirmation { "senha@123" }
    confirmed_at { Time.current }
    role { :customer }

    trait :admin do
      role { :admin }
    end

    trait :customer do
      role { :customer }
    end

    trait :with_profile do
      after(:create) do |user|
        create(:profile, user:)
      end
    end

    # Factory completa pronta para uso nos testes de operações
    factory :customer_with_profile, traits: %i[customer with_profile]
    factory :admin_with_profile,    traits: %i[admin with_profile]
  end
end
