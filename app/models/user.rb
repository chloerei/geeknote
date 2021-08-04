class User < ApplicationRecord
  has_one :account, as: :owner, autosave: true
  has_many :authors
  has_many :author_posts, through: :authors, source: :post
  has_many :members
  has_many :organizations, through: :members
  has_many :manage_accounts, -> { where(members: { role: Member.roles.values_at(:owner, :admin, :editor) })}, through: :organizations, source: :account
  has_many :member_accounts, through: :organizations, source: :account
  has_many :attachments
  has_many :likes
  has_many :liked_posts, through: :likes, source: :likable, source_type: 'Post'
  has_many :notifications
  has_many :follows
  has_many :followings, through: :follows, source: :account
  has_many :following_users, through: :followings, source: :owner, source_type: 'User'
  has_many :bookmarks

  has_secure_password
  has_secure_token :auth_token
  has_one_attached :avatar
  has_one_attached :banner_image

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
    key = Rails.application.key_generator.generate_key 'user-encryptor', ActiveSupport::MessageEncryptor.key_len
    ActiveSupport::MessageEncryptor.new(key)
  end

  def password_reset_token
    User.encryptor.encrypt_and_sign(id, purpose: :password_reset, expires_in: 30.minutes)
  end

  def self.find_by_password_reset_token(token)
    find_by id: User.encryptor.decrypt_and_verify(token, purpose: :password_reset)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    nil
  end
end
