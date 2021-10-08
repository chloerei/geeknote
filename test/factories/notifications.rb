FactoryBot.define do
  factory :notification do
    account factory: :user_account
    user

    factory :comment_notification do
      record factory: :comment
      type { :comment }
    end

    factory :reply_notification do
      record factory: :comment
      type { :reply }
    end

    factory :post_restricted_notification do
      record factory: :post
      type { :post_restricted }
    end
  end
end
