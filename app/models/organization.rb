class Organization < ApplicationRecord
  has_one :account, as: :owner, autosave: true
  has_many :memberships

  validates :name, presence: true

  accepts_nested_attributes_for :account
end
