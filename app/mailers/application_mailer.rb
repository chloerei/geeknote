class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  before_action :set_site

  default from: -> { "#{@site.name} <#{ENV['MAILER_FROM_DEFAULT']}>" }

  private

  def set_site
    @site = Site.first_or_create
  end
end
