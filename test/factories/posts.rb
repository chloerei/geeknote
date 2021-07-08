FactoryBot.define do
  factory :post do
    title { 'Title' }
    content { 'Content' }
    account factory: :user_account

    factory :published_post do
      status { 'published' }
      published_at { Time.now }
    end
  end
end
