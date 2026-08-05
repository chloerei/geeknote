require "test_helper"

class Dashboard::Settings::HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "should get index" do
    sign_in @user
    get dashboard_settings_root_path(@user.account.name)
    assert_response :success
  end

  test "should show profile and export links" do
    sign_in @user
    get dashboard_settings_root_path(@user.account.name)
    assert_response :success
  end

  test "should not show members link for user account" do
    sign_in @user
    get dashboard_settings_root_path(@user.account.name)
    assert_response :success
  end

  test "should show members link for organization account" do
    organization = create(:organization)
    create(:member, organization: organization, user: @user, role: "admin")

    sign_in @user
    get dashboard_settings_root_path(organization.account.name)
    assert_response :success
  end

  test "ordinary member should not get index" do
    organization = create(:organization)
    member = create(:user)
    create(:member, organization: organization, user: member, role: "member")

    sign_in member
    get dashboard_settings_root_path(organization.account.name)
    assert_redirected_to dashboard_root_path(organization.account.name)
  end

  test "should require authentication" do
    get dashboard_settings_root_path(@user.account.name)
    assert_redirected_to new_session_url
  end
end
