require "test_helper"

class Settings::HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  test "should get index" do
    get settings_root_path
    assert_response :success
  end
end
