FactoryBot.define do
  factory :post do
    title { 'Title' }
    content { 'Content' }
    space
    author factory: :user
  end
end
