require "test_helper"

class User::Email::UnsubscribesControllerTest < ActionDispatch::IntegrationTest
  test "should get expire page without token" do
    get user_email_unsubscribe_path
    assert_response :not_found
  end

  test "should get show page with token" do
    user = create(:user)
    get user_email_unsubscribe_path(token: user.email_auth_token, type: "comment")
    assert_response :success
  end

  test "should unsubscribe comment email" do
    user = create(:user)
    assert user.comment_email_notification_enabled?
    patch user_email_unsubscribe_path(token: user.email_auth_token, type: "comment")
    assert_response :success
    user.reload
    assert_not user.comment_email_notification_enabled?
  end

  test "should unsubscribe weekly summary email" do
    user = create(:user)
    assert user.weekly_digest_email_enabled?
    patch user_email_unsubscribe_path(token: user.email_auth_token, type: "weekly_digest")
    assert_response :success
    user.reload
    assert_not user.weekly_digest_email_enabled?
  end
end
