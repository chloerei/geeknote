class Post < ApplicationRecord
  include Taggable
  include Likable
  include Commentable
  include MeiliSearch::Rails

  extend Pagy::Meilisearch

  normalizes :canonical_url, with: ->(url) { url.presence }

  belongs_to :account
  belongs_to :user
  has_many :revisions, class_name: "PostRevision", dependent: :delete_all
  has_many :bookmarks

  has_secure_token :preview_token
  has_one_attached :featured_image do |attachable|
    attachable.variant :large, resize_to_limit: [ 1920, 1920 ]
  end

  enum :status, {
    draft: 0,
    published: 1,
    trashed: 2
  }

  attribute :remove_featured_image, :boolean

  validates :canonical_url, url: true, allow_blank: true
  validates :featured_image, content_type: [ :png, :jpg, :jpeg ], size: { less_than: 5.megabytes }

  before_save :set_published_at
  after_save :condition_remove_featured_image
  after_touch :update_score

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

  def set_published_at
    if published_at.nil? && published?
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

  def update_score
    if published_at && likes_count > 0 && content.length > 100
      update_column :score, (Math.log([ likes_count, 1 ].max, 10) + published_at.to_i / 43200) * 100
    end
  end

  def condition_remove_featured_image
    featured_image.purge_later if remove_featured_image
  end
end
