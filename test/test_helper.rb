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
RubyLLM.config.default_model = "deepseek-v4-flash"

# Where RubyLLM sends a DeepSeek chat completion.
AI_COMPLETION_URL = "https://api.deepseek.com/chat/completions"

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

  # Runs the block with a different default model, restoring the configured one
  # afterwards. Stubbing the model instead of the code under test keeps the AI
  # code paths intact when what is exercised is the missing configuration.
  def with_default_model(model)
    previous_model = RubyLLM.config.default_model
    RubyLLM.config.default_model = model
    yield
  ensure
    RubyLLM.config.default_model = previous_model
  end

  # Stubs the DeepSeek chat completion endpoint so AI calls run without network.
  # The reply is the assistant message content.
  def stub_ai_completion(reply)
    stub_request(:post, AI_COMPLETION_URL).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: {
        id: "chatcmpl-test",
        object: "chat.completion",
        created: 0,
        model: RubyLLM.config.default_model,
        choices: [
          { index: 0, message: { role: "assistant", content: reply }, finish_reason: "stop" }
        ],
        usage: { prompt_tokens: 1, completion_tokens: 1, total_tokens: 2 }
      }.to_json
    )
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
