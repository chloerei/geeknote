require "test_helper"

class Account::PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    account = create(:user_account)
    create(:post, account: account, author: account.owner)
    create(:post, account: create(:organization_account), author: account.owner)

    get account_root_path(account)
    assert_response :success
  end
end
