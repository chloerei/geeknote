class Organization < ApplicationRecord
  has_one :account, as: :owner, autosave: true
  has_many :members
  has_one_attached :avatar
  has_one_attached :banner_image

  validates :name, presence: true

  accepts_nested_attributes_for :account, update_only: true
end
