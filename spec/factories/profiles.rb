FactoryBot.define do
  sequence(:profile_document) { |n| n.to_s.rjust(11, "0") }
  sequence(:profile_phone)    { |n| "479#{n.to_s.rjust(8, '0')}" }

  factory :profile do
    association :user
    full_name { "Usuário Teste" }
    document  { generate(:profile_document) }
    phone     { generate(:profile_phone) }
  end
end
