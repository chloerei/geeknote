require "test_helper"

class Settings::ThemesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  test "should get show" do
    get settings_theme_url
    assert_response :success
  end
end
