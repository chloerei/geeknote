require "test_helper"

class Dashboard::Settings::OrganizationDeletionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = create(:organization)
    @admin = create(:user)
    @admin_member = create(:member, organization: @organization, user: @admin, role: "admin")
  end

  test "admin should get show" do
    sign_in @admin
    get dashboard_settings_organization_deletion_path(@organization.account.name)
    assert_response :success
  end

  test "ordinary member should not get show" do
    member = create(:user)
    create(:member, organization: @organization, user: member, role: "member")

    sign_in member
    get dashboard_settings_organization_deletion_path(@organization.account.name)
    assert_redirected_to dashboard_root_path(@organization.account.name)
  end

  test "should not get show for user account" do
    sign_in @admin
    get dashboard_settings_organization_deletion_path(@admin.account.name)
    assert_redirected_to dashboard_settings_root_path(@admin.account.name)
  end

  test "admin can schedule organization deletion with matching account name" do
    sign_in @admin

    assert_enqueued_with(job: OrganizationDeletionJob, args: [ @organization ]) do
      post dashboard_settings_organization_deletion_path(@organization.account.name),
        params: { name: @organization.account.name }
    end

    assert_redirected_to organizations_url
    assert Organization.exists?(@organization.id)
  end

  test "admin cannot schedule deletion with mismatched account name" do
    sign_in @admin

    assert_no_enqueued_jobs only: OrganizationDeletionJob do
      post dashboard_settings_organization_deletion_path(@organization.account.name),
        params: { name: "wrong-name" }
    end

    assert_response :unprocessable_content
    assert Organization.exists?(@organization.id)
  end

  test "ordinary member cannot schedule deletion" do
    member = create(:user)
    create(:member, organization: @organization, user: member, role: "member")

    sign_in member
    assert_no_enqueued_jobs only: OrganizationDeletionJob do
      post dashboard_settings_organization_deletion_path(@organization.account.name),
        params: { name: @organization.account.name }
    end
    assert_redirected_to dashboard_root_path(@organization.account.name)
  end

  test "should require authentication" do
    get dashboard_settings_organization_deletion_path(@organization.account.name)
    assert_redirected_to new_session_url
  end
end
