require "test_helper"

class Account::FeedControllerTest < ActionDispatch::IntegrationTest
  test "should get user feed" do
    account = create(:user_account)
    create(:post, account: account, author_users: [account.owner])
    get account_feed_path(account, format: :atom)
    assert_response :success
  end

  test "should get organization feed" do
    account = create(:organization_account)
    user = create(:user)
    create(:post, account: account, author_users: [user])
    get account_feed_path(account, format: :atom)
    assert_response :success
  end
end
