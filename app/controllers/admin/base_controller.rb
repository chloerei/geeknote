class Admin::BaseController < ApplicationController
  before_action :require_sign_in, :require_admin

  layout 'admin'

  private

  def require_admin
    unless current_user.admin?
      render_not_found
    end
  end
end
