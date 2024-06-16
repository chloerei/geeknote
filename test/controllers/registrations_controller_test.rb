require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get sign up page" do
    get sign_up_url
    assert_response :success
  end

  test "should create user" do
    post sign_up_url, params: { user: attributes_for(:user) }

    assert current_user
    assert_enqueued_email_with UserMailer, :email_verification, params: { user: current_user }
    assert_redirected_to root_url
  end
end
