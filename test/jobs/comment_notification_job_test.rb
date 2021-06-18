require "test_helper"

class CommentNotificationJobTest < ActiveJob::TestCase
  test "should create notification for post author" do
    user = create(:user)
    post = create(:post, author_users: [user])
    comment = create(:comment, commentable: post)

    assert_difference "user.notifications.count" do
      CommentNotificationJob.perform_now(comment)
    end
  end

  test "should create notification for comment reply" do
    post = create(:post)
    comment = create(:comment, commentable: post)
    reply_comment = create(:comment, account: comment.account, commentable: post, parent: comment)

    assert_difference "comment.user.notifications.count" do
      CommentNotificationJob.perform_now(reply_comment)
    end
  end
end
