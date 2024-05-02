FactoryBot.define do
  factory :collection do
    account factory: :user_account
    name { "Name" }
  end
end
