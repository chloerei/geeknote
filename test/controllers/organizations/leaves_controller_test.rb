require "test_helper"

class Organizations::LeavesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "index shows leave button with confirm dialog" do
    organization = create(:organization, name: "LeaveOrg")
    create(:member, organization: organization, user: @user, role: :member, status: :active)

    sign_in @user
    get organizations_url
    assert_response :success
  end

  test "ordinary member can leave organization" do
    organization = create(:organization, name: "LeaveOrg")
    create(:member, organization: organization, user: @user, role: :member, status: :active)

    sign_in @user
    assert_difference "@user.members.count", -1 do
      delete organization_leave_path(organization)
    end
    assert_redirected_to organizations_url
  end

  test "admin can leave when another admin exists" do
    organization = create(:organization, name: "LeaveOrg")
    create(:member, organization: organization, user: @user, role: :admin)
    other_admin = create(:user)
    create(:member, organization: organization, user: other_admin, role: :admin)

    sign_in @user
    assert_difference "@user.members.count", -1 do
      delete organization_leave_path(organization)
    end
    assert_redirected_to organizations_url
  end

  test "admin cannot leave when the only other admin is pending" do
    organization = create(:organization, name: "LeaveOrg")
    create(:member, organization: organization, user: @user, role: :admin, status: :active)
    pending_admin = create(:user)
    create(:member, organization: organization, user: pending_admin, role: :admin, status: :pending)

    sign_in @user
    assert_no_difference "@user.members.count" do
      delete organization_leave_path(organization)
    end
    assert_redirected_to dashboard_settings_root_path(organization.account.name)
  end

  test "last admin cannot leave organization" do
    organization = create(:organization, name: "LeaveOrg")
    create(:member, organization: organization, user: @user, role: :admin)

    sign_in @user
    assert_no_difference "@user.members.count" do
      delete organization_leave_path(organization)
    end
    assert_redirected_to dashboard_settings_root_path(organization.account.name)
  end

  test "should not leave organization user does not belong to" do
    organization = create(:organization, name: "OtherOrg")

    sign_in @user
    delete organization_leave_path(organization)
    assert_response :not_found
  end

  test "should require authentication" do
    organization = create(:organization)
    delete organization_leave_path(organization)
    assert_redirected_to new_session_url
  end
end
