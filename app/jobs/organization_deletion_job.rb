class OrganizationDeletionJob < ApplicationJob
  queue_as :default

  # Deleting an organization cascades to account, posts, members, etc. so it
  # runs in the background to keep the admin request fast.
  def perform(organization)
    organization.destroy
  end
end
