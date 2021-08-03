class Collection < ApplicationRecord
  belongs_to :account
  has_many :collection_items

  enum visibility: {
    private: 0,
    public: 1
  }, _prefix: true

  validates :name, presence: true

  attribute :added, :boolean, default: false

  scope :with_post_status, -> (post) {
    select(
      sanitize_sql_array(["*, exists(select 1 from collection_items where collection_items.collection_id = collections.id and collection_items.post_id = :post_id ) as added", post_id: post.id])
    )
  }
end
