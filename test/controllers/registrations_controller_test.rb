require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get sign up page" do
    get new_registration_url
    assert_response :success
  end

  test "should create user" do
    post registration_url, params: { user: attributes_for(:user) }

    assert_redirected_to root_url
    user = User.last
    assert_enqueued_email_with UserMailer, :email_verification, params: { user: user }
  end

  test "should not create user with blocked email domain" do
    stub_const(User, :BLOCKED_EMAIL_DOMAINS, [ "spam.com" ]) do
      assert_no_difference("User.count") do
        post registration_url, params: { user: attributes_for(:user).merge(email: "user@spam.com") }
      end
      assert_response :unprocessable_content
    end
  end
end
