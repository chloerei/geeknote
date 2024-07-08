require "test_helper"

class Account::FollowersControllerTest < ActionDispatch::IntegrationTest
  test "should get followers page" do
    account = create(:user_account)
    account.follows.create(user: create(:user_account).owner)

    get account_followers_path(account.name)
    assert_response :success
  end
end
