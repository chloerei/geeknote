class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(comment)
    case comment.commentable
    when Post
      create_post_comment_notification(comment)
    end
  end

  def create_post_comment_notification(comment)
    if comment.user != comment.commentable.author
      Notification.create(type: :comment, user: comment.commentable.author, account: comment.account, record: comment)
    end

    if comment.parent && comment.parent.user != comment.commentable.author && comment.parent.user != comment.user
      Notification.create(type: :reply, user: comment.parent.user, account: comment.account, record: comment)
    end
  end
end
