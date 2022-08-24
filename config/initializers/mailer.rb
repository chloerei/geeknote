case ENV['MAILER_DELIVERY_METHOD']
when 'postal'
  require 'postal-rails'

  ActionMailer::Base.delivery_method = :postal
  ActionMailer::Base.postal_settings = {
    host: ENV['POSTAL_HOST'],
    server_key: ENV['POSTAL_SERVER_KEY']
  }
when 'mailgun'
  require 'mailgun-ruby'

  ActionMailer::Base.delivery_method = :mailgun
  ActionMailer::Base.mailgun_settings = {
    api_key: ENV['MAILGUN_API_KEY'],
    domain: ENV['MAILGUN_DOMAIN']
  }
when 'smtp'
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
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

ActionMailer::Base.default_options = {
  from: ENV['MAILER_DEFAULT_FROM'] || "noreply@example.com"
}

ActionMailer::Base.default_url_options = {
  host: ENV['HOST']
}
