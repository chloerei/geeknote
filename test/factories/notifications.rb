FactoryBot.define do
  factory :notification do
    user

    factory :commented_notification do
      type { "Notification::Commented" }
      data { { comment_id: create(:comment).id } }
    end

    factory :post_blocked_notification do
      type { "Notification::PostBlocked" }
      data { { post_id: create(:post).id } }
    end
  end
end
