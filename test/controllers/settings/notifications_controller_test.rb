require "test_helper"

class Settings::NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  test "should get show" do
    get settings_notification_url
    assert_response :success
  end

  test "should update" do
    patch settings_notification_url, params: { user: { email_notification_enabled: false } }
    assert_redirected_to settings_notification_url
    assert_not @user.reload.email_notification_enabled
  end
end
