class Member < ApplicationRecord
  belongs_to :organization
  belongs_to :user, optional: true
  belongs_to :inviter, class_name: "User", optional: true
  has_secure_token :invitation_token

  enum role: {
    owner: 0,
    admin: 1,
    member: 2
  }

  enum status: {
    pending: 0,
    active: 1
  }

  validates :user_id, uniqueness: { scope: :organization_id }, allow_nil: true
  validates :invitation_email, uniqueness: { scope: :organization_id }, allow_nil: true
  validates :invitation_email, presence: true, if: -> { user_id.nil? }

  def invitation_valid?
    invited_at > 7.day.ago
  end
end
