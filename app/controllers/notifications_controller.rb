class NotificationsController < ApplicationController
  before_action :require_sign_in

  def index
    @notifications = current_user.notifications.page(params[:page])
    current_user.notifications.unread.update_all(read_at: Time.now)
  end
end
