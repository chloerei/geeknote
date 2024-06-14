class Site < ApplicationRecord
  has_one_attached :icon do |attachable|
    attachable.variant :normal, resize_to_fit: [ 512, 512 ]
  end

  has_one_attached :logo do |attachable|
    attachable.variant :normal, resize_to_limit: [ 320, 320 ]
  end

  has_one_attached :logo_dark do |attachable|
    attachable.variant :normal, resize_to_limit: [ 320, 320 ]
  end

  def remove_icon=(value)
    if value
      self.icon = nil
    end
  end

  def remove_logo=(value)
    if value
      self.logo = nil
    end
  end

  def remove_logo_dark=(value)
    if value
      self.logo_dark = nil
    end
  end
end
