class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_site, :set_current_user

  layout "site"

  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from Pagy::OverflowError, with: :render_404

  private

  def render_404
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end

  def set_site
    @site = Site.first_or_create(name: "Geeknote")
    @page_titles = [ @site.name ]
  end

  def require_sign_in
    unless current_user
      return_path = request.get? ? request.path : URI(request.referer.presence || "/").path
      redirect_to sign_in_path(return_to: return_path), alert: t(".require_sign_in")
    end
  end

  def set_current_user
    Current.user = authenticate_by_auth_token
  end

  def current_user
    Current.user
  end

  def authenticate_by_auth_token
    if cookies[:auth_token].present?
      User.find_by(auth_token: cookies[:auth_token])
    end
  end

  def sign_in(user)
    Current.user = user
    cookies[:auth_token] = {
      value: user.auth_token,
      expires: 12.month,
      httponly: true
    }
  end

  def sign_out
    Current.user = nil
    cookies[:auth_token] = nil
  end

  def optional_verify_recaptcha(options = {})
    if defined?(Recaptcha)
      verify_recaptcha(options.with_defaults(attribute: :recaptcha))
    else
      true
    end
  end
end
