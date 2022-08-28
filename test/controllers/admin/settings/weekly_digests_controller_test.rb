require "test_helper"

class Admin::Settings::WeeklyDigestsControllerTest < ActionDispatch::IntegrationTest
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
    patch admin_settings_weekly_digest_path, params: { site: { weekly_digest_email_enabled: false } }
    assert_redirected_to admin_settings_weekly_digest_path
    @site.reload
    assert_equal false, @site.weekly_digest_email_enabled
  end
end
