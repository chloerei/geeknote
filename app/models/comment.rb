class Comment < ApplicationRecord
  include MeiliSearch::Rails
  include Likable

  extend Pagy::Meilisearch

  belongs_to :commentable, polymorphic: true, counter_cache: true, touch: true
  belongs_to :parent, class_name: "Comment", optional: true, counter_cache: :replies_count, touch: true
  belongs_to :user
  has_many :replies, class_name: "Comment", foreign_key: :parent_id

  validates :content, presence: true
  validate :check_parent_comment

  scope :no_parent, -> { where(parent_id: nil) }

  scope :hot, -> {
    select("*, (log(10, greatest(3 * likes_count + replies_count, 1)) + (extract(epoch from created_at) / 43200)) as score").order(score: :desc)
  }

  after_create :create_notifications_later

  meilisearch sanitize: true do
    attribute :user_id, :created_at
    attribute :content do
      CommonMarker.render_html(content.to_s, :DEFAULT, [ :table, :tasklist, :strikethrough, :autolink, :tagfilter ])
    end

    searchable_attributes [ :content ]
    filterable_attributes [ :user_id ]
    sortable_attributes [ :created_at ]

    attributes_to_highlight [ :content ]
    attributes_to_crop [ :content ]
    crop_length 100
    pagination max_total_hits: 1000
  end

  def check_parent_comment
    if parent && parent.commentable != commentable
      errors.add(:parent, :invalid)
    end
  end

  def ancestors
    sql = <<~EOF
      with recursive ancestors as (
        select comments.* from comments where id = :parent_id
        union all
        select comments.* from comments join ancestors on ancestors.parent_id = comments.id
      ) select * from ancestors
    EOF
    Comment.find_by_sql([ sql, { parent_id: parent_id } ])
  end

  def commentable_sgid=(sgid)
    self.commentable = GlobalID::Locator.locate_signed(sgid, for: :commentable)
  end

  def create_notifications_later
    CommentNotificationJob.perform_later(self)
  end
end
