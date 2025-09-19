require "test_helper"

class Settings::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, password: "password")
    sign_in @user
  end

  test "should get show" do
    get settings_password_url
    assert_response :success
  end

  test "should update" do
    patch settings_password_url, params: { user: { password: "newpassword", password_confirmation: "newpassword", password_challenge: "password" } }
    assert_redirected_to settings_password_url
  end

  test "should not update with invalid password" do
    patch settings_password_url, params: { user: { password: "newpassword", password_confirmation: "newpassword", password_challenge: "invalid" } }
    assert_response :unprocessable_content
  end
end
