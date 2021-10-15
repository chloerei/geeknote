require "test_helper"

class User::Email::VerificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get expire page without token" do
    get user_email_verification_path
    assert_response :not_found
  end

  test "should get show page with token" do
    user = create(:user)
    get user_email_verification_path(token: user.email_verification_token)
    assert_response :success
  end

  test "should verifi email" do
    user = create(:user)
    assert_not user.email_verified?
    patch user_email_verification_path(token: user.email_verification_token)
    user.reload
    assert user.email_verified?
  end
end
