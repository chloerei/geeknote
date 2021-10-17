require "test_helper"

class User::Email::UnsubscribesControllerTest < ActionDispatch::IntegrationTest
  test "should get expire page without token" do
    get user_email_unsubscribe_path
    assert_response :not_found
  end

  test "should get show page with token" do
    user = create(:user)
    get user_email_unsubscribe_path(token: user.email_verification_token, type: 'comment')
    assert_response :success
  end

  test "should unsubscribe comment email" do
    user = create(:user)
    assert user.email_notification_comment_enabled?
    patch user_email_unsubscribe_path(token: user.email_verification_token, type: 'comment')
    assert_response :success
    user.reload
    assert_not user.email_notification_comment_enabled?
  end
end
