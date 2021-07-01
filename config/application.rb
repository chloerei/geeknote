require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

module GeekNote
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.autoload_paths << Rails.root.join('lib')

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

    if ENV['MAILER_DELIVERY_METHOD'] == 'smtp'
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
    end

    config.action_mailer.default_options = {
      from: ENV['MAILER_DEFAULT_FROM']
    }
    config.action_mailer.default_url_options = {
      host: ENV['HOST']
    }
  end
end
