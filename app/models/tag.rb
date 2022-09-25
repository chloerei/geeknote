class Tag < ApplicationRecord
  has_many :taggings, dependent: :delete_all
  has_many :posts, through: :taggings, source: :taggable, source_type: 'Post'

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }

  def self.search(query)
    where("name like ?", "#{sanitize_sql_like(query)}%")
  end

  def merge(tag_list)
    tag_list.each do |tag_name|
      tag = Tag.find_by name: tag_name

      if tag && tag != self
        tag.taggings.each do |tagging|
          taggable = tagging.taggable
          taggable.tag_list = taggable.tag_list - [tag_name] + [name]
          taggable.save
        end
        tag.destroy
      end
    end
  end
end
