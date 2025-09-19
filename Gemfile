source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.0.2"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.5.9"
# Use Puma as the app server
gem "puma", "~> 6.6.0"
# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", "~> 0.1.15", require: false
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.13.0"

# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.20"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft", "~> 1.1.0"

# Use Active Storage variant
gem "image_processing", "~> 1.14.0"

gem "active_storage_validations", "~> 2.0.4"

gem "solid_cache", "~> 1.0.7"
gem "solid_cable", "~> 3.0.8"
gem "solid_queue", "~> 1.1.5"
gem "mission_control-jobs", "~> 1.0.2"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18.6", require: false

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0.13"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "~> 1.3.4"

gem "jsbundling-rails"
gem "cssbundling-rails"

# markdown
gem "commonmarker", "~> 0.23.11"

# code highlight
gem "rouge", "~> 4.5.2"

# pagination
gem "pagy", "~> 9.4.0"

# inline email css
gem "premailer-rails", "~> 1.12.0"

gem "rails-i18n", "~> 8.0.1"

gem "local_time", "~> 3.0.3"

gem "aws-sdk-s3", "~> 1.199.0", require: false

gem "imgproxy-rails", "~> 0.3.0"

gem "newrelic_rpm", require: false

# Mailer deliver method
gem "mailgun-ruby", "~> 1.3.5", require: false
gem "postal-rails", "~> 1.0.1", require: false

gem "with_advisory_lock", "~> 5.3.0"

gem "recaptcha", "~> 5.19.0", require: false

gem "rest-client", "~> 2.1.0"

gem "meilisearch-rails", "~> 0.16.0"

gem "jwt", "~> 2.10.1"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.10.0", platforms: %i[ mri windows ]

  gem "factory_bot_rails", "~> 6.5.1"

  gem "dotenv-rails", "~> 3.1.8"

  gem "hotwire-spark", "~> 0.1.13"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", "~> 4.2.1"

  gem "i18n-tasks", github: "chloerei/i18n-tasks"

  gem "brakeman", "~> 7.0.2"

  gem "rubocop-rails-omakase", "~> 1.1.0", require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", "~> 3.40.0"
  gem "selenium-webdriver", "~> 4.10.0"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers", "~> 5.3.1"
  gem "webmock", "~> 3.25.1"
end
