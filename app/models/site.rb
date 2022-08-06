class Site < ApplicationRecord
  has_one_attached :icon do |attachable|
    attachable.variant :normal, resize_to_fit: [256, 256]
  end

  has_one_attached :logo

  has_one_attached :logo_alt

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

  def remove_logo_alt=(value)
    if value
      self.logo_alt = nil
    end
  end
end
