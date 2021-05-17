class Follow < ApplicationRecord
  belongs_to :user, counter_cache: :followings_count
  belongs_to :account, counter_cache: :followers_count

  validates :user_id, uniqueness: { scope: :account_id }
end
