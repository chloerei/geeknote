module Likable
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likable

    attribute :liked

    scope :with_liked, -> (user) {
      if user
        select(
          sanitize_sql_array(["*, exists(select 1 from likes where likes.likable_type = :name and likes.likable_id = #{table_name}.id and likes.user_id = :user_id ) as liked", name: name, user_id: user.id])
        )
      else
        select("*, false as liked")
      end
    }

    def liked_by?(user)
      return false if user.nil?

      likes.where(user: user).exists?
    end
  end
end
