require "test_helper"

class Settings::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "resend verification" do
    sign_in create(:user)
    post resend_settings_email_path
    assert_enqueued_email_with UserMailer, :email_verification, args: { user: current_user }
    assert_redirected_to settings_email_path
  end
end
