require "test_helper"

class Account::PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    account = create(:user_account)
    create(:post, account: account, author_users: [account.owner])
    create(:post, account: create(:organization_account), author_users: [account.owner])

    get account_root_path(account)
    assert_response :success
  end
end
