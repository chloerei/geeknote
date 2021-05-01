class Collection < ApplicationRecord
  belongs_to :account
  has_many :collection_items
  has_many :posts, through: :items

  enum visibility: {
    private: 0,
    public: 1
  }, _prefix: true

  validates :name, presence: true
end
