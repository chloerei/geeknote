class Post < ApplicationRecord
  include Taggable
  include Likable
  include Commentable

  belongs_to :account
  has_many :authors
  has_many :author_users, through: :authors, source: :user
  has_many :revisions, class_name: 'PostRevision', dependent: :delete_all

  has_secure_token :preview_token
  has_one_attached :featured_image

  enum status: {
    draft: 0,
    published: 1,
    trashed: 2
  }

  validates :canonical_url, format: { with: URI.regexp(['http', 'https']) }, allow_blank: true
  validates :feed_source_id, uniqueness: { scope: :account_id }, allow_blank: true

  scope :following_by, -> (user) {
    joins(:authors).where(account: user.followings).or(where(authors: { user: user.following_users } )).distinct
  }

  scope :hot, -> {
    select("*, (log(10, greatest(3 * likes_count + comments_count, 1)) + (extract(epoch from published_at) / 43200)) as score").where("length(content) > 100").where("likes_count > 0").order(score: :desc)
  }

  scope :featured, -> { where(featured: true) }

  attribute :saved, :boolean, default: false

  before_update :set_published_at

  def set_published_at
    if published_at.nil? && status_changed? && status == 'published'
      self.published_at = Time.now
    end
  end

  def author_list=(list)
    if account.organization?
      self.author_users = account.owner.member_users.joins(:account).where(account: { name: list })
    end
  end

  def restricted!
    update(
      restricted: true,
      status: 'draft'
    )

    PostRestrictedNotificationJob.perform_later(self)
  end

  def remove_restricted
    update(
      restricted: false
    )
  end

  def save_revision(status: 'draft', user:)
    last_revision = revisions.last

    if last_revision && last_revision.status == status && last_revision.user == user && last_revision.created_at > 10.minutes.ago
      last_revision.update(
        title: title,
        content: content
      )
    else
      revisions.create(
        user: user,
        status: status,
        title: title,
        content: content
      )
    end
  end

  def canonical_url=(value)
    write_attribute :canonical_url, value.presence
  end
end
