ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

WebMock.disable_net_connect!(allow: [
  ENV.fetch("MEILISEARCH_URL", "http://localhost:7700")
])

User::ADMIN_EMAILS.push "admin@example.com"

# Stub provider credentials so ask_later can build a chat in tests.
RubyLLM.config.deepseek_api_key = "test"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include FactoryBot::Syntax::Methods

  def png_file
    @png_file ||= {
      io: StringIO.new(Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==")),
      filename: "pixel.png",
      content_type: "image/png"
    }
  end
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
