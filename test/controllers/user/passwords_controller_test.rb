require "test_helper"

class User::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "should get new page" do
    get new_user_password_path
    assert_response :success
  end

  test "should not create reset if email not exists" do
    assert_emails 0 do
      post user_password_path, params: { email: 'account@example.com' }
    end
    assert_redirected_to new_user_password_path
  end

  test "should create reset if email exists" do
    user = create(:user)

    assert_emails 1 do
      post user_password_path, params: { email: user.email }
    end
    assert_redirected_to sign_in_path
  end

  test "should not access reset form if token invalid" do
    get edit_user_password_path(token: 'invalid')
    assert_redirected_to new_user_password_path
  end

  test "should access reset form if token valid" do
    user = create(:user)

    get edit_user_password_path(token: user.password_reset_token)
    assert_response :success
  end

  test "should not update if token invalid" do
    patch user_password_path(token: 'invalid')
    assert_redirected_to new_user_password_path
  end

  test "should update if token valid" do
    user = create(:user)
    patch user_password_path(token: user.password_reset_token), params: { user: { password: '12345678', password_confirmation: '12345678'} }
    assert_redirected_to sign_in_path
    assert user.reload.authenticate('12345678')
  end
end
