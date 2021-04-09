class Tagging < ApplicationRecord
  belongs_to :tag, counter_cache: true
  belongs_to :taggable, polymorphic: true
end
