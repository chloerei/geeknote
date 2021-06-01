class Account < ApplicationRecord
  belongs_to :owner, polymorphic: true
  has_many :posts
  has_many :comments
  has_many :attachments
  has_many :follows
  has_many :followers, through: :follows, source: :user
  has_many :follower_accounts, through: :followers, source: :account

  NAME_REGEXP = /\A[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\z/
  validates :name, uniqueness: true, format: { with: NAME_REGEXP }, presence: true

  def to_param
    name
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

  def has_member?(user)
    return false if user.nil?

    case owner
    when User
      owner == user
    when Organization
      owner.memberships.where(user: user).exists?
    else
      false
    end
  end

  def user?
    owner_type == 'User'
  end

  def organization?
    owner_type == 'Organization'
  end
end
