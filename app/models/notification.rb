class Notification < ApplicationRecord
  self.inheritance_column = "_type_disabled"

  belongs_to :account
  belongs_to :user
  belongs_to :record, polymorphic: true

  enum type: {
    comment: 0,
    reply: 1,
    post_restricted: 2
  }

  scope :unread, -> { where(read_at: nil) }
end
