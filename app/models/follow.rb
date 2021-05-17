class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :account

  validates :user_id, uniqueness: { scope: :account_id }
end
