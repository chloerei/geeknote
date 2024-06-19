module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings

    scope :tagged_with, ->(name) { joins(:tags).where(tags: { name: name }) }
  end

  def tag_list
    tags.map(&:name).join(",")
  end

  def tag_list=(names)
    self.tags = names.split(",").map do |name|
      Tag.find_or_create_by(name: name.strip)
    end
  end
end
