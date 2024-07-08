class Notification::Commented < Notification
  after_create :send_email_later

  validate do
    if data["comment_id"].blank?
      errors.add(:data, "comment_id is required")
    end
  end

  def comment
    @comment ||= Comment.find(data["comment_id"])
  end

  def comment=(comment)
    data["comment_id"] = comment.id
  end

  def title
    "#{user.name} commented on #{comment.post.title}"
  end

  def body
    ApplicationController.helpers.markdown_summary(comment.content)
  end

  def url
    Rails.application.routes.url_helpers.account_comment_url(comment.user.account.name, comment)
  end

  def icon
    "comment"
  end

  def send_email_later
    if user.email_verified? && user.comment_email_notification_enabled?
      UserMailer.with(notification: self).commented_notification.deliver_later
    end
  end
end
