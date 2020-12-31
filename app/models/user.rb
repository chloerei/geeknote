class User < ApplicationRecord
  has_secure_password
  has_secure_token :auth_token

  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true
end
