require "test_helper"

class Admin::Settings::AppearancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @site = Site.create
    @admin = create(:user, email: User::ADMIN_EMAILS.last)
  end

  test "should get show page" do
    sign_in @admin
    get admin_settings_appearance_path
    assert_response :success
  end

  test "should update site" do
    sign_in @admin
    patch admin_settings_appearance_path, params: { site: { name: 'changed'} }
    assert_redirected_to admin_settings_appearance_path
    @site.reload
    assert_equal 'changed', @site.name
  end
end
