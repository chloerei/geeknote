class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user, optional: true

  enum role: {
    owner: 0,
    admin: 1,
    member: 2
  }

  enum status: {
    invited: 0,
    accepted: 1
  }

  attr_accessor :identifier

  validates :user_id, uniqueness: { scope: :organization_id }, allow_nil: true
  validates :invite_email, uniqueness: { scope: :organization_id }, allow_nil: true

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
          if organization.memberships.where(invite_email: identifier).exists?
            errors.add :identifier, :already_exists
          else
            self.invite_email = identifier
          end
        end
      else
        errors.add :identifier, :invalid_format
      end
    end
  end
end
