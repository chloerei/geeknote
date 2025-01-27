source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.0.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use Puma as the app server
gem "puma", "~> 6.5.0"
# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"

# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.7"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use Active Storage variant
gem "image_processing", "~> 1.2"

gem "active_storage_validations"

gem "solid_cache", "~> 1.0"
gem "solid_cable", "~> 3.0"
gem "solid_queue", "~> 1.1"
gem "mission_control-jobs", github: "rails/mission_control-jobs"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# markdown
gem "commonmarker", "~> 0.23.8"

# Html to Markdown
gem "reverse_markdown"

# code highlight
gem "rouge"

# pagination
gem "kaminari"
gem "rails_cursor_pagination"
gem "pagy"

# inline email css
gem "premailer-rails"

gem "rails-i18n", "~> 8.0.1"

gem "local_time"

gem "aws-sdk-s3", require: false

gem "imgproxy-rails"

gem "newrelic_rpm", require: false

# Mailer deliver method
gem "mailgun-ruby", "~>1.3.1", require: false
gem "postal-rails", "~> 1.0", require: false

gem "with_advisory_lock"

gem "recaptcha", require: false

gem "rest-client"

gem "meilisearch-rails"

gem "jwt"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  gem "factory_bot_rails"

  gem "dotenv-rails"

  gem "hotwire-spark"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console"

  gem "i18n-tasks", github: "chloerei/i18n-tasks"

  gem "brakeman", "~> 7.0"

  gem "rubocop-rails-omakase", require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"
  gem "webmock"
end
