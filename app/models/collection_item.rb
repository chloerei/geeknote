class CollectionItem < ApplicationRecord
  belongs_to :collection, counter_cache: true
  belongs_to :post

  validates :post_id, uniqueness: { scope: :collection_id }
end
