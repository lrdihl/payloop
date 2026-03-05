FactoryBot.define do
  factory :profile do
    association :user
    full_name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    document  { Faker::Number.number(digits: 11).to_s }  # CPF fake
    phone     { Faker::PhoneNumber.cell_phone }
  end
end
