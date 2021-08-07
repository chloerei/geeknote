class CollectionItem < ApplicationRecord
  belongs_to :collection, touch: true, counter_cache: true
  belongs_to :post
end
