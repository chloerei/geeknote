require "test_helper"

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, email: "admin@example.com")
    sign_in @admin
  end

  test "should enqueue organization deletion job and not destroy synchronously" do
    organization = create(:organization)

    assert_enqueued_with(job: OrganizationDeletionJob, args: [ organization ]) do
      delete admin_organization_url(organization)
    end

    assert_redirected_to admin_organizations_url
    assert Organization.exists?(organization.id)
  end
end
