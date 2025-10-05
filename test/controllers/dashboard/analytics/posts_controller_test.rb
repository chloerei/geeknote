require "test_helper"

class Dashboard::Analytics::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post, account: @user.account, user: @user)
  end

  test "should get index" do
    sign_in @user
    get dashboard_analytics_posts_url(@user.account.name)
    assert_response :success
  end

  test "should get show" do
    sign_in @user
    get dashboard_analytics_post_url(@user.account.name, @post)
    assert_response :success
  end
end
