class Post < ApplicationRecord
  belongs_to :space
  belongs_to :author, class_name: 'User'

  has_secure_token :preview_token
  has_one_attached :featured_image

  enum status: {
    draft: 0,
    published: 1,
    trashed: 2
  }
end
