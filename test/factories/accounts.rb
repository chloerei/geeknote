FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "name#{n}" }
  end
end
