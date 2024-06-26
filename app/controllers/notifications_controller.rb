class NotificationsController < ApplicationController
  before_action :require_sign_in
  after_action :mark_notifications_as_read, only: :index

  layout "site"

  def index
    @pagy, @notifications = pagy(Current.user.notifications.order(created_at: :desc))
  end

  private

  def mark_notifications_as_read
    Current.user.notifications.unread.update_all(read_at: Time.current)
  end
end
