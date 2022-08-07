class ApplicationController < ActionController::Base
  before_action :set_site

  helper_method :current_user

  if Rails.env.production?
    rescue_from StandardError, with: :render_server_error
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  end

  private

  def set_site
    @site = Site.first_or_create
  end

  def render_not_found
    respond_to do |format|
      format.html { render 'errors/404', layout: 'base', status: 404 }
      format.json { render json: { status: 404, error: 'Not Found' }, status: 404 }
    end
  end

  def render_server_error(exception)
    if defined?(Sentry)
      Sentry.capture_exception(exception)
    end

    if defined?(NewRelic)
      NewRelic::Agent.notice_error(exception)
    end

    respond_to do |format|
      format.html { render 'errors/500', layout: 'base', status: 500 }
      format.json { render json: { status: 500, error: 'Internal Server Error' }, status: 500 }
    end
  end

  def require_sign_in
    unless current_user
      return_path = request.get? ? request.path : URI(request.referer.presence || '/').path
      redirect_to sign_in_path(return_to: return_path), alert: t('flash.require_sign_in')
    end
  end

  def current_user
    @current_user ||= authenticate_by_auth_token
  end

  def authenticate_by_auth_token
    if cookies[:auth_token].present?
      User.find_by(auth_token: cookies[:auth_token])
    end
  end

  def sign_in(user)
    @current_user = user
    cookies[:auth_token] = {
      value: user.auth_token,
      expires: 12.month,
      httponly: true
    }
  end

  def sign_out
    @current_user = nil
    cookies[:auth_token] = nil
  end

  def optional_verify_recaptcha(options = {})
    if defined?(Recaptcha)
      verify_recaptcha(options)
    else
      true
    end
  end
end
