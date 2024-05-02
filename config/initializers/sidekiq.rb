Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end

if Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash! YAML.load_file("config/schedule.yml")
end
