require "test_helper"

class Settings::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  test "should get show" do
    get settings_profile_url
    assert_response :success
  end

  test "should update" do
    patch settings_profile_url, params: { user: { name: "New Name" } }
    assert_redirected_to settings_profile_url
    assert_equal "New Name", @user.reload.name
  end
end
