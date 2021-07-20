require "test_helper"

class Account::Dashboard::Posts::StatusesControllerTest < ActionDispatch::IntegrationTest
  test "should publish post" do
    user = create(:user)
    post = create(:post, account: user.account, author_users: [user], status: 'draft')

    sign_in user
    patch account_dashboard_post_status_path(user.account, post), params: { post: { status: 'published' } }, as: :turbo_stream
    post.reload
    assert post.published?
  end

  test "should not publish restricted post" do
    user = create(:user)
    post = create(:post, account: user.account, author_users: [user], status: 'draft', restricted: true)

    sign_in user
    patch account_dashboard_post_status_path(user.account, post), params: { post: { status: 'published' } }, as: :turbo_stream
    post.reload
    assert_not post.published?
  end
end
