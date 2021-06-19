require "test_helper"

class MemberTest < ActiveSupport::TestCase
  setup do
    @organization = create(:organization)
  end

  test "should set identifier as username" do
    user = create(:user)
    member = @organization.members.new(identifier: user.account.name)
    assert member.valid?
    assert_equal user, member.user
  end

  test "should set identifier as user email" do
    user = create(:user)
    member = @organization.members.new(identifier: user.email)
    assert member.valid?
    assert_equal user, member.user
  end

  test "should set identifier as unregister email" do
    member = @organization.members.new(identifier: 'unregister@example.com')
    assert member.valid?
    assert_nil member.user
    assert_equal 'unregister@example.com', member.invitation_email
  end

  test "should not as duplicate identifier" do
    user = create(:user)
    @organization.members.create(user: user)
    @organization.members.create(invitation_email: 'account@example.com')

    member = @organization.members.new(identifier: user.account.name)
    assert_not member.valid?
    assert member.errors.where(:identifier, :already_exists).any?

    member = @organization.members.new(identifier: user.email)
    assert_not member.valid?
    assert member.errors.where(:identifier, :already_exists).any?

    member = @organization.members.new(identifier: 'account@example.com')
    assert_not member.valid?
    assert member.errors.where(:identifier, :already_exists).any?
  end
end
