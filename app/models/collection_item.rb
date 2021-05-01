class CollectionItem < ApplicationRecord
  belongs_to :collection
  belongs_to :post

  validates :post_id, uniqueness: { scope: :collection_id }
end
