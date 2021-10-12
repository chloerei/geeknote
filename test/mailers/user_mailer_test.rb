require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "email verification" do
    user = create(:user)
    email = UserMailer.with(user: user).email_verification
    assert_equal [user.email], email.to
  end

  test "comment notification" do
    user = create(:user)
    parent = create(:comment)
    comment = create(:comment, account: parent.account, commentable: parent.commentable, parent: parent)
    email = UserMailer.with(user: user, comment: comment).comment_notification

    assert_equal [user.email], email.to
    assert_equal "#{comment.account.name}/posts/#{comment.commentable_id}/comments/#{comment.id}@geeknote.net", email.message_id
    assert_equal "#{comment.account.name}/posts/#{comment.commentable_id}@geeknote.net", email.references
    assert_equal "#{comment.account.name}/posts/#{comment.commentable_id}/comments/#{comment.parent_id}@geeknote.net", email.in_reply_to
  end
end
