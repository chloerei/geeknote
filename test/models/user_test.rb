require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "account name should be unique" do
    user_one = create(:user, account_attributes: { name: 'user' })
    assert user_one.valid?
    user_two = build(:user, account_attributes: { name: 'user' })
    assert_not user_two.valid?
    assert user_two.account.errors.where(:name, :taken).any?
  end

  test "account name should be valid format" do
    assert build(:user, account_attributes: { name: 'abc' }).valid?
    assert build(:user, account_attributes: { name: 'a-c' }).valid?

    assert_not build(:user, account_attributes: { name: '' }).valid?
    assert_not build(:user, account_attributes: { name: '-abc' }).valid?
    assert_not build(:user, account_attributes: { name: 'abc-' }).valid?
    assert_not build(:user, account_attributes: { name: 'a.bc' }).valid?
  end
end
