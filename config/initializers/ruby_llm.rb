RubyLLM.configure do |config|
  config.deepseek_api_key = ENV["DEEPSEEK_API_KEY"]
  config.default_model = ENV["AI_MODEL"]
end
