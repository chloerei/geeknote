class Post < ApplicationRecord
  belongs_to :space
  belongs_to :author, class_name: 'User'

  validates :title, :content, presence: true
end
