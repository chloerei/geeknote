class Post < ApplicationRecord
  belongs_to :space
  belongs_to :author, class_name: 'User'

  has_secure_token :preview_token

  enum status: {
    draft: 0,
    published: 1
  }
end
