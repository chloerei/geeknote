class Collection < ApplicationRecord
  belongs_to :account
  has_many :collection_items, dependent: :delete_all
  has_many :posts, through: :collection_items

  enum visibility: {
    private: 0,
    public: 1
  }, _prefix: true

  enum order_type: {
    custom: 0,
    added_asc: 1,
    added_desc: 2,
    published_asc: 3,
    published_desc: 4
  }, _prefix: true

  enum add_to: {
    top: 0,
    bottom: 1
  }, _prefix: true

  validates :name, presence: true

  attribute :added, :boolean, default: false

  scope :with_post_status, ->(post) {
    select(
      sanitize_sql_array([ "*, exists(select 1 from collection_items where collection_items.collection_id = collections.id and collection_items.post_id = :post_id ) as added", post_id: post.id ])
    )
  }

  after_update :reorder, if: :saved_change_to_order_type?

  def with_order_lock
    with_advisory_lock("collection_#{id}_order") do
      yield
    end
  end

  def reorder
    items = case order_type
    when "added_asc"
      self.collection_items.order(created_at: :asc)
    when "added_desc"
      self.collection_items.order(created_at: :desc)
    when "published_asc"
      self.collection_items.joins(:post).order("posts.published_at asc")
    when "published_desc"
      self.collection_items.joins(:post).order("posts.published_at desc")
    else
      self.collection_items.order(position: :asc)
    end

    with_order_lock do
      if items
        items.each_with_index do |item, index|
          item.update_attribute :position, index
        end
      end
    end
  end

  def can_read_by_user?(user)
    if visibility_public?
      true
    else
      if user
        if account.user?
          account.owner == user
        else
          account.owner.members.where(user: user).exists?
        end
      else
        false
      end
    end
  end
end
