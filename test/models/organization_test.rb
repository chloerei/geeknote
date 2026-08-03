require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "destroying an organization deletes all associated resources without raising" do
    organization = create(:organization)
    account = organization.account
    user = create(:user)
    other = create(:user)
    member = create(:member, organization: organization, user: user)
    invitation = create(:invitation, organization: organization, inviter: user)

    post = create(:post, account: account, user: user)
    series = create(:series, account: account)
    follow = create(:follow, user: other, account: account)
    export = create(:export, account: account)

    organization.destroy

    assert organization.destroyed?
    assert_not Organization.exists?(organization.id)
    assert_not Account.exists?(account.id)
    assert_not Post.exists?(post.id)
    assert_not Series.exists?(series.id)
    assert_not Follow.exists?(follow.id)
    assert_not Export.exists?(export.id)
    assert_not Member.exists?(member.id)
    assert_not Member.exists?(invitation.id)

    # the member users are not deleted along with the organization
    assert User.exists?(user.id)
    assert User.exists?(other.id)
  end

  test "destroying an organization does not delete unrelated data" do
    organization = create(:organization)
    account = organization.account
    member_user = create(:user)
    create(:member, organization: organization, user: member_user)
    outsider = create(:user)

    org_post = create(:post, account: account, user: member_user)
    outsider_comment_on_org_post = create(:comment, commentable: org_post, user: outsider)
    outsider_like_on_org_post = create(:like, user: outsider, likable: org_post)

    member_user_post = create(:post, account: member_user.account, user: member_user)
    outsider_post = create(:post, account: outsider.account, user: outsider)

    organization.destroy

    # member users and their personal data survive
    assert User.exists?(member_user.id)
    assert Account.exists?(member_user.account.id)
    assert Post.exists?(member_user_post.id)

    # unrelated users and their data survive
    assert User.exists?(outsider.id)
    assert Account.exists?(outsider.account.id)
    assert Post.exists?(outsider_post.id)

    # other users' comments/likes on the organization's posts are kept (as deleted items)
    assert Comment.exists?(outsider_comment_on_org_post.id)
    assert Like.exists?(outsider_like_on_org_post.id)
  end
end
