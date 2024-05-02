require "test_helper"

class Account::Dashboard::Settings::ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get profile setting page for user" do
    user = create(:user)

    get account_dashboard_settings_profile_path(user.account)
    assert_response :redirect

    sign_in user
    get account_dashboard_settings_profile_path(user.account)
    assert_response :success
  end

  test "should get profile setting page for org admin" do
    organization = create(:organization)

    get account_dashboard_settings_profile_path(organization.account)
    assert_response :redirect

    sign_in create(:member, organization: organization, role: "member").user
    get account_dashboard_settings_profile_path(organization.account)
    assert_response :not_found

    sign_in create(:member, organization: organization, role: "admin").user
    get account_dashboard_settings_profile_path(organization.account)
    assert_response :success
  end

  test "should update profile for user" do
    user = create(:user)

    patch account_dashboard_settings_profile_path(user.account), params: { user: { name: "changed" } }
    assert_response :redirect

    sign_in user
    patch account_dashboard_settings_profile_path(user.account), params: { user: { name: "changed" } }
    assert_redirected_to account_dashboard_settings_profile_path(user.account)
    user.reload
    assert_equal "changed", user.name
  end

  test "should update profile for org" do
    organization = create(:organization)

    patch account_dashboard_settings_profile_path(organization.account), params: { organization: { name: "changed" } }
    assert_response :redirect

    sign_in create(:member, organization: organization, role: "member").user
    patch account_dashboard_settings_profile_path(organization.account), params: { organization: { name: "changed" } }
    assert_response :not_found

    sign_in create(:member, organization: organization, role: "admin").user
    patch account_dashboard_settings_profile_path(organization.account), params: { organization: { name: "changed" } }
    assert_redirected_to account_dashboard_settings_profile_path(organization.account)
    organization.reload
    assert_equal "changed", organization.name
  end
end
