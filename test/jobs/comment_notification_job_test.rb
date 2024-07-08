require "test_helper"

class CommentNotificationJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "should create notification for post author" do
    user = create(:user)
    post = create(:post, user: user)
    comment = create(:comment, commentable: post)

    assert_difference "user.notifications.count" do
      CommentNotificationJob.perform_now(comment)
    end
  end

  test "should create notification for comment reply" do
    post = create(:post)
    comment = create(:comment, commentable: post)
    reply_comment = create(:comment, commentable: post, parent: comment)

    assert_difference "comment.user.notifications.count" do
      CommentNotificationJob.perform_now(reply_comment)
    end
  end
end
