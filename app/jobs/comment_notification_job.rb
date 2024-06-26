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
      Notification::Commented.create(user: post.user, comment: comment)
    end

    # notify reply comment user
    if comment.parent && (post.user != comment.parent.user) && (comment.parent.user != comment.user)
      Notification::Commented.create(user: comment.parent.user, comment: comment)
    end
  end
end
