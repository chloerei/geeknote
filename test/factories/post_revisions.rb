FactoryBot.define do
  factory :post_revision do
    post
    user
    title { "Title" }
    content { "Content" }
  end
end
