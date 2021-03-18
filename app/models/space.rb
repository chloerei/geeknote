class Space < ApplicationRecord
  belongs_to :owner, polymorphic: true

  PATH_REGEXP = /\A[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\z/
  validates :path, uniqueness: true, format: { with: PATH_REGEXP }, presence: true
end
