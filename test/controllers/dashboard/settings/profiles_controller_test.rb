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

  test "should show delete organization button for organization account" do
    organization = create(:organization)
    create(:member, organization: organization, user: @user, role: "admin")

    sign_in @user
    get dashboard_settings_profile_path(organization.account.name)
    assert_response :success
    assert_select "a[href='#{dashboard_settings_organization_deletion_path(organization.account.name)}']"
  end

  test "should not show delete organization button for user account" do
    sign_in @user
    get dashboard_settings_profile_path(@user.account.name)
    assert_response :success
    assert_select "a[href='#{dashboard_settings_organization_deletion_path(@user.account.name)}']", count: 0
  end
end
