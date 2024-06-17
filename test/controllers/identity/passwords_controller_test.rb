require "test_helper"

class Identity::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "should get new page" do
    get new_identity_password_path
    assert_response :success
  end

  test "should not create reset if email not exists" do
    assert_emails 0 do
      post identity_password_path, params: { user: { email: "account@example.com" } }
    end
    assert_response :unprocessable_entity
  end

  test "should create reset if email exists" do
    user = create(:user)

    assert_emails 1 do
      post identity_password_path, params: { user: { email: user.email } }
    end
    assert_redirected_to sign_in_path
  end

  test "should not access reset form if token invalid" do
    get edit_identity_password_path(token: "invalid")
    assert_redirected_to new_identity_password_path
  end

  test "should access reset form if token valid" do
    user = create(:user)

    get edit_identity_password_path(token: user.generate_token_for(:password_reset))
    assert_response :success
  end

  test "should not update if token invalid" do
    patch identity_password_path(token: "invalid")
    assert_redirected_to new_identity_password_path
  end

  test "should update if token valid" do
    user = create(:user)
    patch identity_password_path(token: user.generate_token_for(:password_reset)), params: { user: { password: "12345678", password_confirmation: "12345678" } }
    assert_redirected_to sign_in_path
    assert user.reload.authenticate("12345678")
  end
end
