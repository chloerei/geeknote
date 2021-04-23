require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  setup do
    @organization = create(:organization)
  end

  test "should set identifier as username" do
    user = create(:user)
    membership = @organization.memberships.new(identifier: user.account.path)
    assert membership.valid?
    assert_equal user, membership.user
  end

  test "should set identifier as user email" do
    user = create(:user)
    membership = @organization.memberships.new(identifier: user.email)
    assert membership.valid?
    assert_equal user, membership.user
  end

  test "should set identifier as unregister email" do
    membership = @organization.memberships.new(identifier: 'unregister@example.com')
    assert membership.valid?
    assert_nil membership.user
    assert_equal 'unregister@example.com', membership.invitation_email
  end

  test "should not as duplicate identifier" do
    user = create(:user)
    @organization.memberships.create(user: user)
    @organization.memberships.create(invitation_email: 'account@example.com')

    membership = @organization.memberships.new(identifier: user.account.path)
    assert_not membership.valid?
    assert membership.errors.where(:identifier, :already_exists).any?

    membership = @organization.memberships.new(identifier: user.email)
    assert_not membership.valid?
    assert membership.errors.where(:identifier, :already_exists).any?

    membership = @organization.memberships.new(identifier: 'account@example.com')
    assert_not membership.valid?
    assert membership.errors.where(:identifier, :already_exists).any?
  end
end
