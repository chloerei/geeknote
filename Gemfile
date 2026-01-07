source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.7"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.1.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.6.2"
# Use Puma as the app server
gem "puma", "~> 7.1.0"
# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", "~> 0.1.15", require: false
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.14.1"

# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.20"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft", "~> 1.3.1"

# Use Active Storage variant
gem "image_processing", "~> 1.14.0"

gem "active_storage_validations", "~> 3.0.2"

gem "solid_cache", "~> 1.0.8"
gem "solid_cable", "~> 3.0.8"
gem "solid_queue", "~> 1.2.1"
gem "mission_control-jobs", "~> 1.1.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18.6", require: false

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0.17"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "~> 1.3.4"

gem "jsbundling-rails"
gem "cssbundling-rails"

# markdown
gem "commonmarker", "~> 2.6.1"

# code highlight
gem "rouge", "~> 4.6.1"

# pagination
gem "pagy", "~> 9.4.0"

# inline email css
gem "premailer-rails", "~> 1.12.0"

gem "rails-i18n", "~> 8.0.1"

gem "local_time", "~> 3.0.3"

gem "aws-sdk-s3", "~> 1.208.0", require: false

gem "imgproxy-rails", "~> 0.3.0"

gem "newrelic_rpm", require: false

# Mailer deliver method
gem "mailgun-ruby", "~> 1.4.0", require: false
gem "postal-rails", "~> 1.0.1", require: false

gem "recaptcha", "~> 5.21.1", require: false

gem "meilisearch-rails", "~> 0.16.0"

gem "ahoy_matey", "~> 5.4.1"

gem "chartkick", "~> 5.2"

gem "groupdate", "~> 6.7"

gem "administrate", "~> 1.0.0"

# minitest 6 is not compatible with rails 8.1.1
# https://github.com/rails/rails/issues/56406#issuecomment-3686824808
gem "minitest", "< 6"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.11.0", platforms: %i[ mri windows ]

  gem "factory_bot_rails", "~> 6.5.1"

  gem "dotenv-rails", "~> 3.1.8"

  gem "hotwire-spark", "~> 0.1.13"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", "~> 4.2.1"

  gem "i18n-tasks", github: "chloerei/i18n-tasks"

  gem "brakeman", "~> 7.1.0"

  gem "bundler-audit", require: false

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
