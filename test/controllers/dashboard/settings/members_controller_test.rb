require "test_helper"

class Dashboard::Settings::MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = create(:organization)
    @admin = create(:user)
    @member = create(:member, organization: @organization, user: @admin, role: "admin")
    sign_in @admin
  end

  test "should get index" do
    get dashboard_settings_members_url(@organization.account.name)
    assert_response :success
  end

  test "should get new" do
    get new_dashboard_settings_member_url(@organization.account.name)
    assert_response :success
  end

  test "should create member" do
    assert_difference("@organization.members.count") do
      post dashboard_settings_members_url(@organization.account.name), params: { member: { invitation_email: "member@example.com", role: "member" } }
    end
    assert_redirected_to dashboard_settings_members_url(@organization.account.name)
  end

  test "should get edit" do
    member = create(:member, organization: @organization)
    get edit_dashboard_settings_member_url(@organization.account.name, member)
    assert_response :success
  end

  test "should update member" do
    member = create(:member, organization: @organization)
    patch dashboard_settings_member_url(@organization.account.name, member), params: { member: { role: "admin" } }
    assert_redirected_to dashboard_settings_members_url(@organization.account.name)
  end

  test "should destroy member" do
    member = create(:member, organization: @organization)
    assert_difference("@organization.members.count", -1) do
      delete dashboard_settings_member_url(@organization.account.name, member)
    end
    assert_redirected_to dashboard_settings_members_url(@organization.account.name)
  end

  test "should not destroy last admin" do
    assert_no_difference("@organization.members.count") do
      delete dashboard_settings_member_url(@organization.account.name, @member)
    end
    assert_redirected_to dashboard_settings_members_url(@organization.account.name)
  end
end
