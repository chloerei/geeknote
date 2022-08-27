require "test_helper"

class Admin::Settings::WeeklySummaries::PreviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @site = Site.create
    @admin = create(:user, email: ENV['ADMIN_EMAILS'])
  end

  test "should send preiview to email" do
    sign_in @admin
    assert_enqueued_email_with UserMailer, :weekly_summary, args: { user: @admin } do
      post admin_settings_weekly_summary_preview_path, params: { user: { email: @admin.email } }
    end
    assert_redirected_to admin_settings_weekly_summary_preview_path
  end
end
