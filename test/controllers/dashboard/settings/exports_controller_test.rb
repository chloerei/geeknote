require "test_helper"

class Dashboard::Settings::ExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "should get show" do
    sign_in @user
    get dashboard_settings_export_url(@user.account.name)
    assert_response :success
  end

  test "should create export" do
    sign_in @user

    post dashboard_settings_export_url(@user.account.name)
    assert_redirected_to dashboard_settings_export_url(@user.account.name)
    assert_not_nil @user.account.reload.export
  end
end
