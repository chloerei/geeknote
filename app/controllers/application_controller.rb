class ApplicationController < ActionController::Base
  helper_method :current_user

  private

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
end
