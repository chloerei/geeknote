class Notification::PostBlocked < Notification
  after_create :send_email_later

  validate do
    if data["post_id"].blank?
      errors.add(:data, "post_id is required")
    end
  end

  def post
    @post ||= Post.find(data["post_id"])
  end

  def post=(post)
    data["post_id"] = post.id
  end

  def send_email_later
    if user.email_verified?
      UserMailer.with(notification: self).post_blocked_notification.deliver_later
    end
  end
end
