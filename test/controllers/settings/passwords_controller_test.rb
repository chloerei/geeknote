require "test_helper"

class Settings::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "should update password with current password" do
    user = create(:user, password: 'password')

    sign_in user
    patch settings_password_path, params: { user: { current_password: 'password', password: 'change', password_confirmation: 'change' } }
    user.reload
    assert user.authenticate('change')
  end

  test "should not update password without current password" do
    user = create(:user, password: 'password')

    sign_in user
    patch settings_password_path, params: { user: { current_password: 'wrong', password: 'change', password_confirmation: 'change' } }
    user.reload
    assert user.authenticate('password')
    assert_not user.authenticate('change')
  end
end
