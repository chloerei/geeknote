if ENV['SENTRY_DSN']
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']

    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    config.traces_sample_rate = 0.5
  end
end