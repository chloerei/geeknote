FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User#{n}" }
    sequence(:email) { |n| "username#{n}@example.com" }
    password { SecureRandom.base58 }
    association :account, strategy: :build
  end
end
