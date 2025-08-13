ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

WebMock.disable_net_connect!(allow: [
  ENV.fetch("MEILISEARCH_URL", "http://localhost:7700")
])

User::ADMIN_EMAILS.push "admin@example.com"

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
    session = user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = session.id
      cookies[:session_id] = cookie_jar[:session_id]
    end
  end

  def sign_out
    cookies.delete(:session_id)
  end
end
