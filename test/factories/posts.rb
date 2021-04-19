FactoryBot.define do
  factory :post do
    title { 'Title' }
    content { 'Content' }
    account
    author factory: :user
  end
end
