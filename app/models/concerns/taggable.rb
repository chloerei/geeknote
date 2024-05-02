module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings

    scope :tagged_with, ->(name) { joins(:tags).where(tags: { name: name }) }

    def tag_list
      tags.pluck(:name)
    end

    def tag_list=(list)
      self.tags = list.uniq.map { |name| Tag.find_or_initialize_by name: name }
    end
  end
end
