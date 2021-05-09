FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "name#{n}" }

    factory :user_account do
      owner factory: :user
    end

    factory :organization_account do
      owner factory: :organization
    end
  end
end
