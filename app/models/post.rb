class Post < ApplicationRecord
  belongs_to :space
  belongs_to :author, class_name: 'User'

  enum status: {
    draft: 0,
    published: 1
  }
end
