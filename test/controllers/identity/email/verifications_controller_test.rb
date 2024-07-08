require "test_helper"

class Identity::Email::VerificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get expire page without token" do
    get identity_email_verification_path
    assert_response :not_found
  end

  test "should get show page with token" do
    user = create(:user)
    get identity_email_verification_path(token: user.generate_token_for(:email_verification))
    assert_response :success
  end

  test "should verifi email" do
    user = create(:user)
    assert_not user.email_verified?
    patch identity_email_verification_path(token: user.generate_token_for(:email_verification))
    user.reload
    assert user.email_verified?
  end
end
