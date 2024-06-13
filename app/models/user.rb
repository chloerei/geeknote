class User < ApplicationRecord
  has_one :account, as: :owner, autosave: true
  has_many :posts
  has_many :members
  has_many :organizations, through: :members
  has_many :manage_accounts, -> { where(members: { role: Member.roles.values_at(:owner, :admin) }) }, through: :organizations, source: :account
  has_many :member_accounts, through: :organizations, source: :account
  has_many :attachments
  has_many :likes
  has_many :liked_posts, through: :likes, source: :likable, source_type: "Post"
  has_many :notifications
  has_many :follows
  has_many :followings, through: :follows, source: :account
  has_many :following_users, through: :followings, source: :owner, source_type: "User"
  has_many :bookmarks
  has_many :bookmarked_posts, through: :bookmarks, source: :post
  has_many :bookmarked_post_tags, through: :bookmarked_posts, source: :tags

  has_secure_password
  has_secure_token :auth_token

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 320, 320 ]
  end

  has_one_attached :banner_image do |attachable|
    attachable.variant :large, resize_to_limit: [ 1920, 1920 ]
  end

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

  def self.encryptor
    key = Rails.application.key_generator.generate_key "user-encryptor", ActiveSupport::MessageEncryptor.key_len
    ActiveSupport::MessageEncryptor.new(key)
  end

  def password_reset_token
    User.encryptor.encrypt_and_sign(id, purpose: :password_reset, expires_in: 30.minutes)
  end

  def self.find_by_password_reset_token(token)
    find_by id: User.encryptor.decrypt_and_verify(token.to_s, purpose: :password_reset)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    nil
  end

  def email_auth_token
    User.encryptor.encrypt_and_sign([ id, email ], purpose: :email_verification, expires_in: 1.week)
  end

  def self.find_by_email_auth_token(token)
    id, email = User.encryptor.decrypt_and_verify(token.to_s, purpose: :email_verification)
    find_by id: id, email: email
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    nil
  end

  def email_verified?
    email_verified_at.present?
  end

  def email_verified!
    update(email_verified_at: Time.now)
  end

  before_update :reset_email_veification, if: :email_changed?

  def reset_email_veification
    self.email_verified_at = nil
  end

  ADMIN_EMAILS = ENV.fetch("ADMIN_EMAILS", "").split(",")
  def admin?
    ADMIN_EMAILS.include?(email)
  end
end
