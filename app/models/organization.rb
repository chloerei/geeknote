class Organization < ApplicationRecord
  has_one :account, as: :owner, autosave: true

  validates :name, presence: true

  accepts_nested_attributes_for :account
end
