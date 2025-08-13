class Admin::BaseController < ApplicationController
  before_action :require_authentication, :require_admin

  layout "admin"

  private

  def require_admin
    unless Current.user.admin?
      render file: Rails.root.join("public", "404.html"), status: :not_found, layout: false
    end
  end
end
