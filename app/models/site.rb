class Site < ApplicationRecord
  has_one_attached :icon do |attachable|
    attachable.variant :normal, resize_to_fit: [256, 256]
  end

  has_one_attached :logo do |attachable|
    attachable.variant :normal, resize_to_limit: [256, 256]
  end

  has_one_attached :logo_alt do |attachable|
    attachable.variant :normal, resize_to_limit: [256, 256]
  end
end
