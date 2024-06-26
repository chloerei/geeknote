class Notification < ApplicationRecord
  belongs_to :user

  scope :unread, -> { where(read_at: nil) }

  # after_create :send_email_later

  def send_email_later
    if user.enable_notification_email?
      UserMailer.with(notification: self).notification.deliver_later
    end
  end

  def title
    raise "Not implemented"
  end

  def body
    raise "Not implemented"
  end

  def url
    raise "Not implemented"
  end

  def icon
    raise "Not implemented"
  end
end
