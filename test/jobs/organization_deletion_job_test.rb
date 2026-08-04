require "test_helper"

class OrganizationDeletionJobTest < ActiveJob::TestCase
  test "destroys the organization and their account" do
    organization = create(:organization)
    create(:post, account: organization.account)

    OrganizationDeletionJob.perform_now(organization)

    assert_not Organization.exists?(organization.id)
    assert_not Account.exists?(organization.account.id)
    assert_empty Post.where(account: organization.account)
  end
end
