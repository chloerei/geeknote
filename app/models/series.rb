class Series < ApplicationRecord
  belongs_to :account

  enum :add_new_at, {
    bottom: 0,
    top: 1
  }, prefix: true
end
