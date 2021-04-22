class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum role: {
    owner: 0,
    admin: 1,
    member: 2
  }

  enum status: {
    pending: 0,
    accepted: 1
  }
end
