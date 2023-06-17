ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'

WebMock.disable_net_connect!(allow: [
  ENV.fetch("MEILISEARCH_URL", "http://localhost:7700")
])

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include FactoryBot::Syntax::Methods
end

class ActionDispatch::IntegrationTest
  def sign_in(user)
    cookies[:auth_token] = user.auth_token
  end

  def sign_out
    cookies[:auth_token] = nil
  end

  def current_user
    User.find_by(auth_token: cookies[:auth_token]) if cookies[:auth_token].present?
  end
end
