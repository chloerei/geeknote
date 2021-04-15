class Space < ApplicationRecord
  belongs_to :owner, polymorphic: true
  has_many :posts

  PATH_REGEXP = /\A[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\z/
  validates :path, uniqueness: true, format: { with: PATH_REGEXP }, presence: true

  def to_param
    path
  end

  def post_tags
    Tag.joins(:posts).where(posts: { space_id: self.id }).distinct
  end
end
