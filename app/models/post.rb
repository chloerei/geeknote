class Post < ApplicationRecord
  include Taggable
  include Likable
  include Commentable

  belongs_to :account
  belongs_to :author, class_name: 'User'
  has_many :collection_items

  has_secure_token :preview_token
  has_one_attached :featured_image

  enum status: {
    draft: 0,
    published: 1,
    trashed: 2
  }

  scope :following_by, -> (user) {
    where(account: user.followings).or(where(author: user.following_users))
  }

  before_update :set_published_at

  def set_published_at
    if published_at.nil? && status_changed? && status == 'published'
      self.published_at = Time.now
    end
  end
end
