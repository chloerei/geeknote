require "test_helper"

class Dashboard::Settings::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @organization = create(:organization)
    create(:member, organization: @organization, user: @user, role: "admin")
  end

  test "should get show" do
    sign_in @user
    get dashboard_settings_profile_path(@organization.account.name)
    assert_response :success
  end

  test "should update profile" do
    sign_in @user
    patch dashboard_settings_profile_path(@organization.account.name), params: { organization: { name: "Change" } }
    assert_redirected_to dashboard_settings_profile_path(@organization.account.name)
  end

  test "should not get show for user account" do
    sign_in @user
    get dashboard_settings_profile_path(@user.account.name)
    assert_redirected_to dashboard_settings_root_path(@user.account.name)
  end

  test "ordinary member should not get show" do
    member = create(:user)
    create(:member, organization: @organization, user: member, role: "member")

    sign_in member
    get dashboard_settings_profile_path(@organization.account.name)
    assert_redirected_to dashboard_root_path(@organization.account.name)
  end
end
