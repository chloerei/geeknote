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
      end
    end

    # notify reply comment user
    if comment.parent && !comment.commentable.author_users.include?(comment.parent.user) && comment.parent.user != comment.user
      Notification.create(type: :reply, user: comment.parent.user, account: comment.account, record: comment)
    end
  end
end
