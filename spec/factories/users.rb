FactoryBot.define do
  factory :user do
    email    { Faker::Internet.unique.email }
    password { "senha@123" }
    password_confirmation { "senha@123" }
    confirmed_at { Time.current }
    role { :consumer }

    trait :admin do
      role { :admin }
    end

    trait :consumer do
      role { :consumer }
    end

    trait :with_profile do
      after(:create) do |user|
        create(:profile, user:)
      end
    end

    # Factory completa pronta para uso nos testes de operações
    factory :consumer_with_profile, traits: %i[consumer with_profile]
    factory :admin_with_profile,    traits: %i[admin with_profile]
  end
end
