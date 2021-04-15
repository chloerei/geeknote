class Tag < ApplicationRecord
  has_many :taggings
  has_many :posts, through: :taggings, source: :taggable, source_type: 'Post'

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }

  def self.search(query)
    where("name like ?", "#{sanitize_sql_like(query)}%")
  end
end
