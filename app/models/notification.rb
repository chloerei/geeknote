class Notification < ApplicationRecord
  belongs_to :user

  scope :unread, -> { where(read_at: nil) }
end
