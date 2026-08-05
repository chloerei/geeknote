require "test_helper"

class UserDeletionJobTest < ActiveJob::TestCase
  test "destroys the user, their account, posts and comments" do
    user = create(:user)
    create(:post, user: user, account: user.account)
    create(:comment, user: user)

    UserDeletionJob.perform_now(user)

    assert_not User.exists?(user.id)
    assert_not Account.exists?(user.account.id)
    assert_empty Post.where(user: user)
    assert_empty Comment.where(user: user)
  end
end
