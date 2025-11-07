# Use by mission control jobs interface
class Admin::BaseController < ActionController::Base
  include Authentication

  before_action :require_authentication
  before_action :authenticate_admin

  private

  def authenticate_admin
    unless Current.user&.admin?
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end
end
