require "test_helper"

class Account::Posts::PreviewsControllerTest < ActionDispatch::IntegrationTest
  test "should get post preview" do
    account = create(:user_account)
    post = create(:post, account: account, author_users: [account.owner])
    post.save_revision(user: account.owner)

    get account_post_preview_path(account, post)
    assert_response :not_found

    get account_post_preview_path(account, post, token: post.preview_token)
    assert_response :success
  end
end
