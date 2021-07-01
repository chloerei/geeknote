class Member < ApplicationRecord
  belongs_to :organization
  belongs_to :user, optional: true
  belongs_to :inviter, class_name: 'User', optional: true
  has_secure_token :invitation_token

  enum role: {
    owner: 0,
    admin: 1,
    editor: 2,
    writer: 3,
    contributor: 4
  }

  PERMISSIONS = Hash.new([])
  PERMISSIONS['contributor'] = []
  PERMISSIONS['writer'] = PERMISSIONS['contributor'] + [:publish_own_post]
  PERMISSIONS['editor'] = PERMISSIONS['writer'] + [:edit_other_post, :publish_other_post, :manage_member]
  PERMISSIONS['admin'] = PERMISSIONS['editor'] + [:edit_account_settings]
  PERMISSIONS['owner'] = PERMISSIONS['admin'] + []

  def has_permission?(name)
    PERMISSIONS[role].include?(name)
  end

  def can_edit_post?(post)
    role.in?(%w(owner admin editor)) || post.authors.include?(user)
  end

  enum status: {
    pending: 0,
    active: 1
  }

  attr_accessor :identifier

  validates :user_id, uniqueness: { scope: :organization_id }, allow_nil: true
  validates :invitation_email, uniqueness: { scope: :organization_id }, allow_nil: true

  validate :validate_identifier, on: :create

  scope :invitations, -> { where(status: :pending).where("invited_at > ?", 7.days.ago) }

  def validate_identifier
    if identifier
      case identifier
      when Account::NAME_REGEXP
        user = User.joins(:account).find_by(account: { name: identifier })

        if user
          if organization.members.where(user: user).exists?
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
          if organization.members.where(user: user).exists?
            errors.add :identifier, :already_exists
          else
            self.user = user
          end
        else
          if organization.members.where(invitation_email: identifier).exists?
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
