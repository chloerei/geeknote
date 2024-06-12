class Organization < ApplicationRecord
  has_one :account, as: :owner, autosave: true
  has_many :members

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 320, 320 ], preprocessed: true
  end

  has_one_attached :banner_image do |attachable|
    attachable.variant :large, resize_to_limit: [ 1920, 1920 ], preprocessed: true
  end

  validates :name, presence: true

  accepts_nested_attributes_for :account, update_only: true
end
