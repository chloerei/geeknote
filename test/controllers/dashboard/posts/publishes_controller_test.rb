require "test_helper"

class Dashboard::Posts::PublishesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post, account: @user.account, user: @user)
  end

  test "should publish post" do
    sign_in @user
    patch dashboard_post_publish_url(@post.account.name, @post)
    @post.reload
    assert @post.published?
  end

  test "should unpublish post" do
    sign_in @user
    @post.published!
    delete dashboard_post_publish_url(@post.account.name, @post)
    @post.reload
    assert @post.draft?
  end
end
