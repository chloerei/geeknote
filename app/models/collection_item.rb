class CollectionItem < ApplicationRecord
  belongs_to :collection, touch: true
  belongs_to :post
end
