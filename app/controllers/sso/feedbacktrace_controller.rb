class Sso::FeedbacktraceController < ApplicationController
  before_action :require_sign_in

  def show
    token = JWT.encode({
      iat: Time.now.to_i,
      external_id: current_user.id,
      email: current_user.email,
      name: current_user.name,
      username: current_user.account.name
    }, Rails.configuration.x.feedbacktrace_jwt_sso_secret_key, "HS256")

    uri = URI(Rails.configuration.x.feedbacktrace_jwt_sso_callback_url)
    uri.query = URI.encode_www_form(token: token)

    redirect_to uri.to_s, allow_other_host: true
  end
end
