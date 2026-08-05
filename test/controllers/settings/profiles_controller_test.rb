require "test_helper"

class Settings::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "should get show" do
    sign_in @user
    get settings_profile_path
    assert_response :success
  end

  test "should update profile" do
    sign_in @user
    patch settings_profile_path, params: { user: { name: "Change" } }
    assert_redirected_to settings_profile_path
    assert_equal "Change", @user.reload.name
  end

  test "should require authentication" do
    get settings_profile_path
    assert_redirected_to new_session_url
  end
end
