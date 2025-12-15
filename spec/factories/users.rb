FactoryBot.define do
  factory :headquarter do
    name { "営業本部" }
    sequence(:code) { |n| "SALES-#{n}" }
  end

  factory :department do
    sequence(:name) { |n| "第#{n}営業部" }
    association :headquarter
  end

  factory :user do
    sequence(:name) { |n| "テスト太郎#{n}" }
    
    sequence(:email) { |n| "test-#{n}@example.com" }

    password { "password123" }
    password_confirmation { "password123" }

    association :department
  end
end