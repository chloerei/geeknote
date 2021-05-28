class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  enum status: {
    saved: 0,
    archived: 1
  }
end
