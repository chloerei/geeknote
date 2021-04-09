module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings

    scope :tagged_with, -> (name) { joins(:tags).where(tags: { name: name }) }
  end
end
