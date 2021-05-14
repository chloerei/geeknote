require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get notification index" do
    user = create(:user)
    create(:comment_notification, user: user)
    create(:reply_notification, user: user)

    assert_equal 2, user.notifications.unread.count
    sign_in user
    get notifications_path
    assert_response :success
    assert_equal 0, user.notifications.unread.count
  end
end
