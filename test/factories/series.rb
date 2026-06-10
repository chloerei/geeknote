FactoryBot.define do
  factory :series do
    account factory: :user_account
    title { "Series Title" }
  end
end
