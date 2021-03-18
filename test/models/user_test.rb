require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "username should be unique" do
    user_one = create(:user, username: 'path')
    assert user_one.valid?
    user_two = build(:user, username: 'path')
    assert_not user_two.valid?
    assert user_two.errors.add(:username, :taken)
  end

  test "username should be valid format" do
    assert build(:user, username: 'abc').valid?
    assert build(:user, username: 'a-c').valid?

    assert_not build(:user, username: '').valid?
    assert_not build(:user, username: '-abc').valid?
    assert_not build(:user, username: 'abc-').valid?
    assert_not build(:user, username: 'a.bc').valid?
  end
end
