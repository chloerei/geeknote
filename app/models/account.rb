class Account < ApplicationRecord
  belongs_to :owner, polymorphic: true
  has_many :posts

  PATH_REGEXP = /\A[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\z/
  validates :path, uniqueness: true, format: { with: PATH_REGEXP }, presence: true

  def to_param
    path
  end

  def post_tags
    Tag.joins(:posts).where(posts: { account_id: self.id }).distinct
  end

  def can_manage_by?(user)
    return false if user.nil?

    case owner
    when User
      owner == user
    when Organization
      owner.memberships.find_by(user: user)&.role&.in? %w(owner admin)
    else
      false
    end
  end
end
