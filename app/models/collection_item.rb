class CollectionItem < ApplicationRecord
  belongs_to :collection, counter_cache: :posts_count
  belongs_to :post, counter_cache: :collections_count

  validates :post_id, uniqueness: { scope: :collection_id }
end
