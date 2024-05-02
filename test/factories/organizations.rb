FactoryBot.define do
  factory :organization do
    name { "Name" }
    association :account, strategy: :build
  end
end
