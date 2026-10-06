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

  def tag_list=(value)
    # names are citext, so two entries differing only in case resolve to the
    # same tag: dedupe before assigning or the tagging insert violates its
    # uniqueness index.
    self.tags = value.split(",").map do |name|
      Tag.find_or_create_by(name: name.strip)
    end.uniq
  end
end
