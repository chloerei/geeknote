class User < ApplicationRecord
  has_one :account, as: :owner, autosave: true
  has_many :posts, foreign_key: :author_id, inverse_of: :author
  has_many :memberships
  has_many :organizations, through: :memberships
  has_many :manage_accounts, -> { where(memberships: { role: Membership.roles.values_at(:admin, :owner) })}, through: :organizations, source: :account
  has_many :member_accounts, through: :organizations, source: :account
  has_many :attachments
  has_many :likes
  has_many :liked_posts, through: :likes, source: :likable, source_type: 'Post'
  has_many :notifications
  has_many :follows
  has_many :followings, through: :follows, source: :account
  has_many :following_users, through: :followings, source: :owner, source_type: 'User'

  has_secure_password
  has_secure_token :auth_token
  has_one_attached :avatar
  has_one_attached :cover

  validates :name, presence: true
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true

  # only for error display
  attr_accessor :current_password, :require_password
  validate :current_password do
    if require_password && !authenticate(current_password)
      errors.add :current_password, :not_match
    end
  end

  accepts_nested_attributes_for :account, update_only: true
end
