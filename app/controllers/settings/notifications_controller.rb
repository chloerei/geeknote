class Settings::NotificationsController < Settings::BaseController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    @user.update settings_params
    flash.now[:notice] = I18n.t('flash.notification_settings_updated')
  end

  private

  def settings_params
    params.require(:user).permit(:email_notification_enabled, :comment_email_notification_enabled, :weekly_summary_email_enabled)
  end
end
