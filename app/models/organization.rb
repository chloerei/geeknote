class Organization < ApplicationRecord
  has_one :account, as: :owner, autosave: true
  has_many :memberships
  has_one_attached :avatar

  validates :name, presence: true

  accepts_nested_attributes_for :account, update_only: true
end
