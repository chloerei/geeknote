class Post < ApplicationRecord
  include Taggable
  include Likable
  include Commentable

  belongs_to :account
  has_many :authors
  has_many :author_users, through: :authors, source: :user
  has_many :bookmarks

  has_secure_token :preview_token
  has_one_attached :featured_image

  enum status: {
    draft: 0,
    published: 1,
    trashed: 2
  }

  scope :following_by, -> (user) {
    joins(:authors).where(account: user.followings).or(where(authors: { user: user.following_users } )).distinct
  }

  scope :hot, -> {
    select("*, (log(10, greatest(3 * likes_count + comments_count, 1)) + (extract(epoch from published_at) / 43200)) as score").order(score: :desc)
  }

  scope :featured, -> { where(featured: true) }

  attribute :saved, :boolean, default: false

  scope :with_statuses, -> (user) {
    if user
      select(
        sanitize_sql_array(["
          posts.*,
          exists(select 1 from likes where likes.likable_type = :name and likes.likable_id = posts.id and likes.user_id = :user_id ) as liked,
          exists(select 1 from bookmarks where bookmarks.post_id = posts.id and bookmarks.user_id = :user_id ) as saved
          ", name: name, user_id: user.id])
      )
    else
      select("posts.*, false as liked, false as saved")
    end
  }

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
end
