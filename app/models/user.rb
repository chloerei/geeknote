class User < ApplicationRecord
  has_one :space, as: :owner, autosave: true
  has_many :posts, as: :author

  has_secure_password
  has_secure_token :auth_token

  validates :name, presence: true
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true

  before_validation :set_space
  after_validation :set_username_error

  def set_space
    if space
      space.path = username
    else
      build_space(path: username)
    end
  end

  def set_username_error
    space.errors.details[:path].each do |error|
      errors.add(:username, error[:error], **error.except(:error, :value))
    end
  end
end
