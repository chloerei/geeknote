require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "should validate name exclusion" do
    account = build(:account)

    account.name = "notspecial"
    account.valid?
    assert_not account.errors.added? :name, :exclusion

    account.name = "admin"
    account.valid?
    assert account.errors.added? :name, :exclusion

    account.name = "Admin"
    account.valid?
    assert account.errors.added? :name, :exclusion
  end

  test "destroying an account deletes all associated resources without raising" do
    user = create(:user)
    account = user.account
    other = create(:user)

    post = create(:post, account: account, user: user)
    series = create(:series, account: account)
    series_post = create(:post, account: account, user: user, series: series)
    attachment = create(:attachment, user: user, account: account, file: png_file)
    follower = create(:follow, user: other, account: account)
    export = create(:export, account: account)

    account.destroy

    assert account.destroyed?
    assert_not Account.exists?(account.id)
    assert_not Post.exists?(post.id)
    assert_not Post.exists?(series_post.id)
    assert_not Series.exists?(series.id)
    assert_not Attachment.exists?(attachment.id)
    assert_not Follow.exists?(follower.id)
    assert_not Export.exists?(export.id)

    # the owner is not deleted along with the account
    assert User.exists?(user.id)
    assert_nil user.reload.account
  end

  test "destroying an account does not delete the owner or other users' data" do
    user = create(:user)
    account = user.account
    other = create(:user)

    post = create(:post, account: account, user: user)
    other_comment_on_account_post = create(:comment, commentable: post, user: other)
    other_like_on_account_post = create(:like, user: other, likable: post)
    other_bookmark_on_account_post = create(:bookmark, user: other, post: post)

    other_post = create(:post, account: other.account, user: other)
    other_notification = create(:notification, user: other)
    # the owner's outbound follow of another account is not touched
    user_follow = create(:follow, user: user, account: other.account)

    account.destroy

    assert User.exists?(user.id)
    assert User.exists?(other.id)
    assert Account.exists?(other.account.id)
    assert Post.exists?(other_post.id)
    assert Notification.exists?(other_notification.id)
    assert Follow.exists?(user_follow.id)

    # other users' comments/likes/bookmarks on the account's posts are kept
    assert Comment.exists?(other_comment_on_account_post.id)
    assert Like.exists?(other_like_on_account_post.id)
    assert Bookmark.exists?(other_bookmark_on_account_post.id)
  end
end
