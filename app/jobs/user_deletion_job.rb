class UserDeletionJob < ApplicationJob
  queue_as :default

  # Deleting a user cascades to account, posts, comments, attachments, likes,
  # notifications, sessions, etc. so it runs in the background to keep the
  # admin request fast.
  def perform(user)
    user.destroy
  end
end
