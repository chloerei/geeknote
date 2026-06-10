class Series < ApplicationRecord
  belongs_to :account
  has_many :posts

  validates :title, presence: true

  enum :add_new_at, {
    bottom: 0,
    top: 1
  }, prefix: true
end
