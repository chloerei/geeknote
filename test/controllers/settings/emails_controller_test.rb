require "test_helper"

class Settings::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, password: "password")
    sign_in @user
  end

  test "should get show" do
    get settings_email_url
    assert_response :success
  end

  test "should update" do
    patch settings_email_url, params: { user: { email: "new@example.com", password_challenge: "password" } }
    assert_redirected_to settings_email_url
    assert_equal "new@example.com", @user.reload.email
    assert_enqueued_emails 1
  end

  test "should not update with invalid password" do
    patch settings_email_url, params: { user: { email: "new@example.com", password_challenge: "wrong" } }
    assert_response :unprocessable_content
    assert_not_equal "new@example.com", @user.reload.email
  end

  test "should resend email verification" do
    assert_enqueued_email_with UserMailer, :email_verification, params: { user: @user } do
      post resend_settings_email_url
    end

    assert_redirected_to settings_email_url
  end
end
