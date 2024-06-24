FactoryBot.define do
  factory :comment do
    commentable factory: :post
    user
    content { "Comtent" }
  end
end
