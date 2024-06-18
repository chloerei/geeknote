class Post < ApplicationRecord
  include Taggable
  include Likable
  include Commentable
  include MeiliSearch::Rails

  extend Pagy::Meilisearch

  belongs_to :account
  belongs_to :user
  has_many :revisions, class_name: "PostRevision", dependent: :delete_all
  has_many :bookmarks

  has_secure_token :preview_token
  has_one_attached :featured_image do |attachable|
    attachable.variant :large, resize_to_limit: [ 1920, 1920 ]
  end

  attribute :remove_featured_image, :boolean

  after_save do
    featured_image.purge_later if remove_featured_image
  end

  # TODO: remove and clean trashed post
  enum status: {
    draft: 0,
    published: 1,
    trashed: 2
  }

  validates :canonical_url, url: true, allow_blank: true
  validates :feed_source_id, uniqueness: { scope: :account_id }, allow_blank: true

  scope :following_by, ->(user) {
    where(account: user.followings).or(where(user: user.following_users)).distinct
  }

  scope :featured, -> { where(featured: true) }

  meilisearch sanitize: true do
    attribute :title, :status, :account_id, :user_id, :score, :published_at, :created_at, :updated_at
    attribute :content do
      CommonMarker.render_html(content.to_s, :DEFAULT, [ :table, :tasklist, :strikethrough, :autolink, :tagfilter ])
    end

    searchable_attributes [ :title, :content ]
    filterable_attributes [ :status, :account_id, :user_id ]
    sortable_attributes [ :score, :published_at, :created_at, :updated_at ]

    attributes_to_highlight [ :title, :content ]
    attributes_to_crop [ :content ]
    crop_length 100
    pagination max_total_hits: 1000
  end

  attribute :saved, :boolean, default: false

  before_save :set_published_at

  def set_published_at
    if published_at.nil? && status == "published"
      self.published_at = Time.now
    end
  end

  def restricted!
    update(
      restricted: true,
      status: "draft"
    )

    PostRestrictedNotificationJob.perform_later(self)
  end

  def remove_restricted
    update(
      restricted: false
    )
  end

  def canonical_url=(value)
    write_attribute :canonical_url, value.presence
  end

  def remove_featured_image=(value)
    if value && featured_image.attached?
      self.featured_image = nil
    end
  end

  after_touch :update_score
  def update_score
    if published? && likes_count > 0 && content.length > 100
      update_column :score, (Math.log([ likes_count + comments_count, 1 ].max, 10) + published_at.to_i / 43200) * 100
    end
  end
end
