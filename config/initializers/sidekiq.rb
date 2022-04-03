Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

if Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash! YAML.load_file("config/schedule.yml")
end
