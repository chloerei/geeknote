class Sso::FeedbacktraceController < ApplicationController
  before_action :require_authentication
  layout "application"

  def show
  end

  def create
    token = JWT.encode({
      exp: 1.minute.from_now.to_i,
      external_id: Current.user.id,
      email: Current.user.email,
      name: Current.user.name,
      username: Current.user.account.name
    }, Rails.configuration.x.feedbacktrace_jwt_sso_secret_key, "HS256")

    uri = URI(Rails.configuration.x.feedbacktrace_jwt_sso_callback_url)
    uri.query = URI.encode_www_form(token: token)

    redirect_to uri.to_s, allow_other_host: true
  end
end
