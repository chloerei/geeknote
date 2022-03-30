require "test_helper"

class Account::PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    account = create(:user_account)
    create(:post, account: account, author_users: [account.owner])
    create(:post, account: create(:organization_account), author_users: [account.owner])

    get account_root_path(account)
    assert_response :success
  end

  test "should get published post" do
    account = create(:user_account)
    post = create(:post, account: account, author_users: [account.owner])
    post.published!
    post.save_revision(status: 'published', user: account.owner)

    get account_post_path(account, post)
    assert_response :success
  end

  test "should not get post by author path" do
    account = create(:organization_account)
    user = create(:user_account).owner
    post = create(:post, account: account, author_users: [user])
    post.published!
    post.save_revision(status: 'published', user: user)

    get account_post_path(account, post)
    assert_response :success

    get account_post_path(user.account, post)
    assert_response :not_found
  end
end
