class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend

  before_action :set_site

  layout "site"

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

  def optional_verify_recaptcha(options = {})
    if defined?(Recaptcha)
      verify_recaptcha(options.with_defaults(attribute: :recaptcha))
    else
      true
    end
  end

  def current_user
    Current.user
  end
end
