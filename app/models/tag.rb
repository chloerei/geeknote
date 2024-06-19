class Tag < ApplicationRecord
  has_many :taggings, dependent: :delete_all
  has_many :posts, through: :taggings, source: :taggable, source_type: "Post"

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }

  scope :trending, -> {
    left_outer_joins(:taggings).where("taggings.created_at > ?", 1.month.ago).distinct.select("tags.*, count(taggings.*) as count").group("tags.id").order("count desc")
  }

  def self.search(query)
    where("name like ?", "#{sanitize_sql_like(query)}%")
  end

  def merge(tag_list)
    tag_list.split(",").each do |tag_name|
      tag = Tag.find_by name: tag_name

      if tag && tag != self
        tag.taggings.each do |tagging|
          taggable = tagging.taggable
          taggable.tags.destroy(tag)
          if !taggable.tags.exists?(self.id)
            taggable.tags << self
          end
        end
        tag.destroy
      end
    end
  end
end
