class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user, optional: true
  belongs_to :inviter, class_name: 'User', optional: true
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

  attr_accessor :identifier

  validates :user_id, uniqueness: { scope: :organization_id }, allow_nil: true
  validates :invitation_email, uniqueness: { scope: :organization_id }, allow_nil: true

  validate :validate_identifier, on: :create

  def validate_identifier
    if identifier
      case identifier
      when Account::PATH_REGEXP
        user = User.joins(:account).find_by(account: { path: identifier })

        if user
          if organization.memberships.where(user: user).exists?
            errors.add :identifier, :already_exists
          else
            self.user = user
          end
        else
          errors.add :identifier, :username_not_exists
        end
      when URI::MailTo::EMAIL_REGEXP
        user = User.find_by(email: identifier)

        if user
          if organization.memberships.where(user: user).exists?
            errors.add :identifier, :already_exists
          else
            self.user = user
          end
        else
          if organization.memberships.where(invitation_email: identifier).exists?
            errors.add :identifier, :already_exists
          else
            self.invitation_email = identifier
          end
        end
      else
        errors.add :identifier, :invalid_format
      end
    end
  end

  def invitation_exipred?
    pending? && invited_at && invited_at < 7.days.ago
  end
end
