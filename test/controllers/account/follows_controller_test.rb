require "test_helper"

class Account::FollowsControllerTest < ActionDispatch::IntegrationTest
  test "should follow account" do
    account = create(:user_account)
    user = create(:user)

    sign_in user
    assert_difference "account.followers.count" do
      post account_follow_path(account)
    end
  end

  test "should unfollow account" do
    account = create(:user_account)
    user = create(:user)
    account.follows.create(user: user)

    sign_in user
    assert_difference "account.followers.count", -1 do
      delete account_follow_path(account)
    end
  end
end
