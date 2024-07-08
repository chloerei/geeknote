class Settings::NotificationsController < Settings::BaseController
  def show
  end

  def update
    @user.update settings_params
    redirect_to settings_notification_path, notice: t(".success")
  end

  private

  def settings_params
    params.require(:user).permit(:email_notification_enabled, :comment_email_notification_enabled, :weekly_digest_email_enabled)
  end
end
