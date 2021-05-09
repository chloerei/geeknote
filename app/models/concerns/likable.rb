module Likable
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likable

    def liked_by?(user)
      return false if user.nil?

      likes.where(user: user).exists?
    end
  end
end
