FactoryBot.define do
  factory :post do
    title { 'Title' }
    content { 'Content' }
    account factory: :user_account
  end
end
