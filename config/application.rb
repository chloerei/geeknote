require_relative 'boot'

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

if ENV['SENTRY_DSN'].present?
  require 'sentry-ruby'
  require 'sentry-rails'
end

if ENV['NEW_RELIC_LICENSE_KEY'].present?
  require 'newrelic_rpm'
end

if ENV['MAILER_DELIVERY_METHOD'] == 'mailgun'
  require 'mailgun-ruby'
end

if ENV['RECAPTCHA_SITE_KEY'].present?
  require 'recaptcha'
end

module GeekNote
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.autoload_paths << Rails.root.join('lib')

    # Stop Propshaft compile all assets
    config.after_initialize do
      config.assets.paths = [
        Rails.root.join("app/assets/builds"),
        Rails.root.join("app/assets/images")
      ]
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.i18n.available_locales = ["zh-CN"]
    config.i18n.default_locale = "zh-CN"

    config.cache_store = :redis_cache_store, {
      url: ENV["REDIS_URL"],
      namespace: 'cache',
      expires_in: 1.day
    }

    config.active_job.queue_adapter = :sidekiq

    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.view_specs false
    end

    config.action_view.field_error_proc = Proc.new do |html_tag|
      html_tag.html_safe
    end

    config.active_storage.service = ENV['STORAGE_SERVICE'] || :local

    case ENV['MAILER_DELIVERY_METHOD']
    when 'smtp'
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = {
        address: ENV['SMTP_ADDRESS'],
        port: ENV['SMTP_PORT'],
        domain: ENV['SMTP_DOMAIN'],
        user_name: ENV['SMTP_USERNAME'],
        password: ENV['SMTP_PASSWORD'],
        authentication: 'plain',
        enable_starttls_auto: true,
        ssl: ENV['SMTP_SSL'].present?
      }
    when 'mailgun'
      config.action_mailer.delivery_method = :mailgun
      config.action_mailer.mailgun_settings = {
        api_key: ENV['MAILGUN_API_KEY'],
        domain: ENV['MAILGUN_DOMAIN']
      }
    end

    config.action_mailer.default_options = {
      from: ENV['MAILER_DEFAULT_FROM'] || "noreply@example.com"
    }
    config.action_mailer.default_url_options = {
      host: ENV['HOST']
    }
  end
end
