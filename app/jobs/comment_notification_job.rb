class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(comment)
    case comment.commentable
    when Post
      create_post_comment_notification(comment)
    end
  end

  def create_post_comment_notification(comment)
    post = comment.commentable

    # notify post author
    if comment.user != post.user
      Notification.create(type: :comment, user: post.user, record: comment)

      if post.user.email_verified? && post.user.email_notification_enabled? && post.user.comment_email_notification_enabled?
        UserMailer.with(user: post.user, comment: comment).comment_notification.deliver_later
      end
    end

    # notify reply comment user
    if comment.parent && (post.user != comment.parent.user) && (comment.parent.user != comment.user)
      user = comment.parent.user

      Notification.create(type: :reply, user: user, record: comment)

      if user.email_verified? && user.email_notification_enabled? && user.comment_email_notification_enabled?
        UserMailer.with(user: comment.parent.user, comment: comment).comment_notification.deliver_later
      end
    end
  end
end
