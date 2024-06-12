class Export < ApplicationRecord
  enum status: {
    pending: 0,
    completed: 1
  }

  belongs_to :account
  has_one_attached :file
end
