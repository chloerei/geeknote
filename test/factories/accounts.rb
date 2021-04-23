FactoryBot.define do
  factory :account do
    sequence(:path) { |n| "path#{n}" }
  end
end
