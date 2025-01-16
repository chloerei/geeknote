require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if ENV["NEW_RELIC_LICENSE_KEY"].present?
  require "newrelic_rpm"
end

module GeekNote
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    config.autoload_paths << Rails.root.join("lib")

    config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")
    config.assets.excluded_paths << Rails.root.join("app/assets/javascripts")

    config.importmap.cache_sweepers << Rails.root.join("app/assets/builds")

    config.asset_host = ENV["ASSET_HOST"]

    if ENV["IMGPROXY_ENDPOINT"].present?
      config.active_storage.resolve_model_to_route = :custom_imgproxy_active_storage
    end

    config.action_dispatch.trusted_proxies = ENV.fetch("TRUSTED_PROXIES", "").split(",").map { |proxy| IPAddr.new(proxy) }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.i18n.available_locales = [ "zh-CN" ]
    config.i18n.default_locale = "zh-CN"

    config.active_job.queue_adapter = :sidekiq

    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.view_specs false
    end

    config.action_view.field_error_proc = Proc.new do |html_tag|
      html_tag.html_safe
    end

    config.active_storage.service = ENV["STORAGE_SERVICE"] || :local

    config.x.host = ENV.fetch("HOST", "localhost")

    config.x.feedbacktrace_jwt_sso_callback_url = ENV["FEEDBACKTRACE_JWT_SSO_CALLBACK_URL"]
    config.x.feedbacktrace_jwt_sso_secret_key = ENV["FEEDBACKTRACE_JWT_SSO_SECRET_KEY"]
  end
end
