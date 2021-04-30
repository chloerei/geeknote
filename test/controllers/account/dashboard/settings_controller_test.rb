require "test_helper"

class Account::Dashboard::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get settings index by user" do
    user = create(:user)

    sign_in user
    get account_dashboard_settings_path(user.account)
    assert_response :success
  end

  test "should get settings index by org admin" do
    organization = create(:organization)

    sign_in create(:membership, organization: organization).user
    get account_dashboard_settings_path(organization.account)
    assert_response :not_found

    sign_in create(:membership, organization: organization, role: 'admin').user
    get account_dashboard_settings_path(organization.account)
    assert_response :success
  end
end
