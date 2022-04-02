class Attachment < ApplicationRecord
  belongs_to :account
  belongs_to :user, optional: true
  has_one_attached :file
  has_secure_token :key
end
