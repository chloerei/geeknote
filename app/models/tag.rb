class Tag < ApplicationRecord
  has_many :taggings
  has_many :taggables, through: :taggings

  validates :tag, presence: true, uniqueness: true, length: { maximum: 255 }
end
