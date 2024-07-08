class Notification < ApplicationRecord
  belongs_to :user

  scope :unread, -> { where(read_at: nil) }

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
