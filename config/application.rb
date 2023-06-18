require_relative 'boot'

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if ENV['SENTRY_DSN'].present?
  require 'sentry-ruby'
  require 'sentry-rails'
end

if ENV['NEW_RELIC_LICENSE_KEY'].present?
  require 'newrelic_rpm'
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
      url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
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

  end
end
