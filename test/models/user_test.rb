require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should reject email with blocked domain on create" do
    stub_const(User, :BLOCKED_EMAIL_DOMAINS, %w[spam.com blocked.org]) do
      assert_not build(:user, email: "user@spam.com").valid?
      assert_not build(:user, email: "user@BLOCKED.org").valid?
      assert build(:user, email: "user@example.com").valid?
    end
  end

  test "should allow blocked domain email on update for existing users" do
    user = create(:user, email: "existing@spam.com")
    assert user.valid?

    user.update(name: "New Name")
    assert user.valid?
  end

  test "account name should be unique" do
    user_one = create(:user, account_attributes: { name: "user" })
    assert user_one.valid?
    user_two = build(:user, account_attributes: { name: "user" })
    assert_not user_two.valid?
    assert user_two.account.errors.where(:name, :taken).any?
  end

  test "account name should be valid format" do
    assert build(:user, account_attributes: { name: "abc" }).valid?
    assert build(:user, account_attributes: { name: "a-c" }).valid?

    assert_not build(:user, account_attributes: { name: "" }).valid?
    assert_not build(:user, account_attributes: { name: "-abc" }).valid?
    assert_not build(:user, account_attributes: { name: "abc-" }).valid?
    assert_not build(:user, account_attributes: { name: "a.bc" }).valid?
  end

  test "should update email verified status" do
    user = create(:user)
    assert_not user.email_verified?

    user.email_verified!
    assert user.email_verified?

    user.update(email: "change@example.com")
    assert_not user.email_verified?
  end

  test "destroying a user deletes all records owned by the user" do
    user = create(:user)
    account = user.account
    other = create(:user)

    post = create(:post, account: account, user: user)
    series = create(:series, account: account)
    comment = create(:comment, commentable: post, user: user)
    reply = create(:comment, commentable: post, user: user, parent: comment)
    like = create(:like, user: user, likable: post)
    bookmark = create(:bookmark, user: user, post: post)
    follow = create(:follow, user: user, account: other.account)
    notification = create(:notification, user: user)
    member = create(:member, user: user)
    session = create(:session, user: user)
    attachment = create(:attachment, user: user, file: png_file)
    visit = Ahoy::Visit.create!(user: user, visit_token: "visit-token-1", visitor_token: "visitor-token-1", started_at: Time.current)
    event = Ahoy::Event.create!(visit: visit, user: user, name: "Test event", time: Time.current)
    export = create(:export, account: account)

    user.destroy

    assert user.destroyed?
    assert_not User.exists?(user.id)
    assert_not Account.exists?(account.id)
    assert_not Post.exists?(post.id)
    assert_not Series.exists?(series.id)
    assert_not Comment.exists?(comment.id)
    assert_not Comment.exists?(reply.id)
    assert_not Like.exists?(like.id)
    assert_not Bookmark.exists?(bookmark.id)
    assert_not Follow.exists?(follow.id)
    assert_not Notification.exists?(notification.id)
    assert_not Member.exists?(member.id)
    assert_not Session.exists?(session.id)
    assert_not Attachment.exists?(attachment.id)
    assert_not Export.exists?(export.id)
    assert_not Ahoy::Visit.exists?(visit.id)
    assert_not Ahoy::Event.exists?(event.id)
  end

  test "destroying a user does not delete other users' data" do
    user = create(:user)
    other = create(:user)

    other_post = create(:post, account: other.account, user: other)
    other_comment = create(:comment, commentable: other_post, user: other)
    other_like = create(:like, user: other, likable: other_post)
    other_bookmark = create(:bookmark, user: other, post: other_post)
    other_notification = create(:notification, user: other)
    other_member = create(:member, user: other)
    invited_member = create(:member, user: other, inviter: user)

    # content the deleted user left on other users' posts
    user_comment_on_other_post = create(:comment, commentable: other_post, user: user)
    user_like_on_other_post = create(:like, user: user, likable: other_post)

    # other users' content on the deleted user's post
    user_post = create(:post, account: user.account, user: user)
    other_comment_on_user_post = create(:comment, commentable: user_post, user: other)
    other_like_on_user_post = create(:like, user: other, likable: user_post)
    other_bookmark_on_user_post = create(:bookmark, user: other, post: user_post)

    # other users following the deleted user's account
    follower_follow = create(:follow, user: other, account: user.account)

    user.destroy

    assert User.exists?(other.id)
    assert Account.exists?(other.account.id)
    assert Post.exists?(other_post.id)
    assert Comment.exists?(other_comment.id)
    assert Like.exists?(other_like.id)
    assert Bookmark.exists?(other_bookmark.id)
    assert Notification.exists?(other_notification.id)
    assert Member.exists?(other_member.id)

    # invitations the deleted user sent are kept but unlinked from them
    assert Member.exists?(invited_member.id)
    assert_nil invited_member.reload.inviter_id

    # the deleted user's comments/likes on other users' posts are removed
    assert_not Comment.exists?(user_comment_on_other_post.id)
    assert_not Like.exists?(user_like_on_other_post.id)

    # other users' comments/likes/bookmarks on the deleted user's posts are kept
    assert Comment.exists?(other_comment_on_user_post.id)
    assert Like.exists?(other_like_on_user_post.id)
    assert Bookmark.exists?(other_bookmark_on_user_post.id)

    # ...except follows pointing at the deleted account, which is destroyed
    assert_not Follow.exists?(follower_follow.id)
  end

  test "destroying a user deletes posts they authored on organization accounts but keeps the organization" do
    organization = create(:organization)
    organization_account = organization.account
    user = create(:user)
    create(:member, organization: organization, user: user)
    org_post = create(:post, account: organization_account, user: user)

    user.destroy

    assert_not Post.exists?(org_post.id)
    assert Organization.exists?(organization.id)
    assert Account.exists?(organization_account.id)
  end
end
