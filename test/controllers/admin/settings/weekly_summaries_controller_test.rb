require "test_helper"

class Admin::Settings::WeeklySummariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @site = Site.create
    @admin = create(:user, email: ENV['ADMIN_EMAILS'])
  end

  test "should get show page" do
    sign_in @admin
    get admin_settings_appearance_path
    assert_response :success
  end

  test "should update site" do
    sign_in @admin
    patch admin_settings_weekly_summary_path, params: { site: { weekly_summary_email_enabled: false } }
    assert_redirected_to admin_settings_weekly_summary_path
    @site.reload
    assert_equal false, @site.weekly_summary_email_enabled
  end
end
