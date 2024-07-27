class Organization < ApplicationRecord
  has_one :account, as: :owner, autosave: true
  has_many :members

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 320, 320 ]
  end

  has_one_attached :banner_image do |attachable|
    attachable.variant :large, resize_to_limit: [ 1920, 1920 ]
  end

  attribute :remove_avatar, :boolean
  attribute :remove_banner_image, :boolean

  after_save do
    avatar.purge_later if remove_avatar
    banner_image.purge_later if remove_banner_image
  end

  validates :name, presence: true
  validates :avatar, content_type: [ :png, :jpg, :jpeg ], size: { less_than: 5.megabytes }
  validates :banner_image, content_type: [ :png, :jpg, :jpeg ], size: { less_than: 5.megabytes }

  accepts_nested_attributes_for :account, update_only: true
end
