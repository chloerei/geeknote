require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get notification index" do
    user = create(:user)
    Notification::Commented.create(user: user, comment: create(:comment))

    assert_equal 1, user.notifications.unread.count
    sign_in user
    get notifications_path
    assert_response :success
    assert_equal 0, user.notifications.unread.count
  end

  test "should not raise exception if notify record is deleted" do
    user = create(:user)
    comment = create(:comment)
    Notification::Commented.create(user: user, comment: comment)

    comment.destroy
    sign_in user
    get notifications_path
    assert_response :success
  end
end
