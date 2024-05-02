FactoryBot.define do
  factory :comment do
    account factory: :user_account
    commentable factory: :post
    user
    content { "Comtent" }
  end
end
