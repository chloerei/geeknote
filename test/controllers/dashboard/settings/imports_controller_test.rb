require "test_helper"

class Dashboard::Settings::ImportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "should get show" do
    sign_in @user
    get dashboard_settings_import_path(@user.account.name)
    assert_response :success
  end

  test "should update" do
    sign_in @user
    patch dashboard_settings_import_path(@user.account.name), params: { account: { feed_url: "http://example.com/feed.xml" } }
    assert_redirected_to dashboard_settings_import_path(@user.account.name)
  end
end
