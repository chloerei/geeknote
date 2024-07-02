require "test_helper"

class Account::PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    account = create(:user_account)
    create(:post, account: account, user: account.owner)
    create(:post, account: create(:organization_account), user: account.owner)

    get account_root_path(account.name)
    assert_response :success
  end

  test "should get published post" do
    account = create(:user_account)
    post = create(:post, account: account, user: account.owner)
    post.published!

    get account_post_path(account.name, post)
    assert_response :success
  end

  test "should not get post by author path" do
    account = create(:organization_account)
    user = create(:user_account).owner
    post = create(:post, account: account, user: user)
    post.published!

    get account_post_path(account.name, post)
    assert_response :success

    assert_raise ActiveRecord::RecordNotFound do
      get account_post_path(user.account.name, post)
    end
  end
end
