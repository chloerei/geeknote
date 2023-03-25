class Post < ApplicationRecord
  include Taggable
  include Likable
  include Commentable

  belongs_to :account
  belongs_to :user
  has_many :revisions, class_name: 'PostRevision', dependent: :delete_all
  has_many :collection_items, dependent: :delete_all

  has_secure_token :preview_token
  has_one_attached :featured_image
  has_one_attached :social_image

  # TODO: remove and clean trashed post
  enum status: {
    draft: 0,
    published: 1,
    trashed: 2
  }

  validates :canonical_url, url: true, allow_blank: true
  validates :feed_source_id, uniqueness: { scope: :account_id }, allow_blank: true

  scope :following_by, -> (user) {
    where(account: user.followings).or(where(user: user.following_users)).distinct
  }

  scope :featured, -> { where(featured: true) }

  attribute :saved, :boolean, default: false

  before_save :set_published_at

  def set_published_at
    if published_at.nil? && status == 'published'
      self.published_at = Time.now
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

  def remove_featured_image=(value)
    if value && featured_image.attached?
      self.featured_image = nil
    end
  end

  after_save :generate_social_image, if: :saved_change_to_title?

  def generate_social_image
    PostGenerateSocialImageJob.perform_later(self)
  end

  after_touch :update_score
  def update_score
    if published? && likes_count > 0 && content.length > 100
      update_column :score, (Math.log([likes_count + comments_count, 1].max, 10) + published_at.to_i / 43200) * 100
    end
  end
end
