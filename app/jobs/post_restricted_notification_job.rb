class PostRestrictedNotificationJob < ApplicationJob
  queue_as :default

  def perform(post)
    post.user.notifications.create(
      account: post.account,
      record: post,
      type: "post_restricted"
    )

    UserMailer.with(user: post.user, post: post).post_restricted_email.deliver_later
  end
end
