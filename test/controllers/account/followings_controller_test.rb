require "test_helper"

class Account::FollowingsControllerTest < ActionDispatch::IntegrationTest
  test "should get following page" do
    user = create(:user_account).owner
    user.follows.create(account: create(:user_account))
    user.follows.create(account: create(:organization_account))

    get account_followings_path(user.account.name)
    assert_response :success
  end
end
