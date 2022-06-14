class Account < ApplicationRecord
  belongs_to :owner, polymorphic: true
  has_many :posts
  has_many :comments
  has_many :attachments
  has_many :follows
  has_many :followers, through: :follows, source: :user
  has_many :follower_accounts, through: :followers, source: :account
  has_many :collections
  has_many :exports

  NAME_REGEXP = /\A[a-zA-Z0-9][a-zA-Z0-9\-]{1,61}[a-zA-Z0-9]\z/
  validates :name, uniqueness: true, format: { with: NAME_REGEXP }, presence: true
  validates :feed_url, url: true, allow_blank: true

  NAME_EXCLUSION_LIST = %w(
    admin
    attachments
    bookmarks
    login
    notifications
    organizations
    posts
    rails
    sessions
    settings
    tags
    users
  ) + ENV.fetch('ACCOUNT_NAME_EXCLUSION_LIST', '').split(',')

  validate :validate_name_exclusion

  def validate_name_exclusion
    if name && name.downcase.in?(NAME_EXCLUSION_LIST)
      errors.add(:name, :exclusion)
    end
  end

  scope :recommend_for, -> (user) {
    where(
      id: Account.distinct.joins(:posts).where("posts.published_at > ?", 3.month.ago).where("followers_count > 0").where.not(id: user&.account&.id)
    ).order("random()")
  }

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
      owner.members.find_by(user: user)&.role&.in? %w(owner admin)
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
      owner.members.where(user: user).exists?
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

  def display_name
    owner.name
  end

  def description
    user? ? owner.bio : owner.description
  end

  def feed_url=(value)
    write_attribute :feed_url, value.presence
  end

  def used_tags
    Tag.joins(:posts).where(posts: { account_id: id }).group("tags.name").order("count_all desc").count()
  end
end
