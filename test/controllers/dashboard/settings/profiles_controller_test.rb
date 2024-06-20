require "test_helper"

class Dashboard::Settings::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "should get show" do
    sign_in @user
    get dashboard_settings_profile_path(@user.account.name)
    assert_response :success
  end

  test "should update profile" do
    sign_in @user
    patch dashboard_settings_profile_path(@user.account.name), params: { user: { name: "Change" } }
    assert_redirected_to dashboard_settings_profile_path
  end
end
