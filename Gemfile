source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.2.3'
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use Active Storage variant
gem 'image_processing', '~> 1.2'

# Job Queue
gem 'sidekiq', '~> 6.0'
gem 'hiredis'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# ENV
gem 'dotenv-rails'

gem 'turbo-rails'

# markdown
gem 'commonmarker'

# Html to Markdown
gem 'reverse_markdown'

# code highlight
gem 'rouge'

# pagination
gem 'kaminari'

# inline email css
gem 'premailer-rails'

gem 'rails-i18n', '~> 7.0.1'

gem 'local_time'

gem "activestorage-aliyun", "~> 1.1"

gem "sentry-ruby", require: false
gem "sentry-rails", require: false

gem 'newrelic_rpm', require: false

gem 'mailgun-ruby', '~>1.2.5', require: false

gem 'with_advisory_lock'

gem 'diffy'

gem "recaptcha"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  gem 'factory_bot_rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'

  gem 'i18n-tasks', '~> 0.9.34'

  gem 'brakeman'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'webmock'
end
