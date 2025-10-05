require "test_helper"

class Dashboard::Analytics::HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post, account: @user.account, user: @user)
  end

  test "should get index" do
    sign_in @user
    get dashboard_analytics_root_url(@user.account.name)
    assert_response :success
  end
end
