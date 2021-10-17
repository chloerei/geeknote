class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(comment)
    case comment.commentable
    when Post
      create_post_comment_notification(comment)
    end
  end

  def create_post_comment_notification(comment)
    # notify authors
    comment.commentable.author_users.each do |user|
      if comment.user != user
        Notification.create(type: :comment, user: user, account: comment.account, record: comment)

        if user.email_verified? && user.email_notification_enabled? && user.comment_email_notification_enabled?
          UserMailer.with(user: user, comment: comment).comment_notification.deliver_later
        end
      end
    end

    # notify reply comment user
    if comment.parent && !comment.commentable.author_users.include?(comment.parent.user) && comment.parent.user != comment.user
      user = comment.parent.user

      Notification.create(type: :reply, user: user, account: comment.account, record: comment)

      if user.email_verified? && user.email_notification_enabled? && user.comment_email_notification_enabled?
        UserMailer.with(user: comment.parent.user, comment: comment).comment_notification.deliver_later
      end
    end
  end
end
