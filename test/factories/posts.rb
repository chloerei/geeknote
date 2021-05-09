FactoryBot.define do
  factory :post do
    title { 'Title' }
    content { 'Content' }
    account factory: :user_account
    author factory: :user
  end
end
