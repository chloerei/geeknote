class Settings::NotificationsController < Settings::BaseController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    @user.update settings_params
    redirect_to settings_notification_path, notice: I18n.t("flash.notification_settings_updated")
  end

  private

  def settings_params
    params.require(:user).permit(:email_notification_enabled, :comment_email_notification_enabled, :weekly_digest_email_enabled)
  end
end
