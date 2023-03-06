class Settings::EmailsController < Settings::BaseController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    @user.require_password = true
    if @user.update user_params
      redirect_to settings_email_path, notice: t('flash.email_update_successful')
    else
      render :show, status: :unprocessable_entity
    end
  end

  def resend
    cache_key = "email_verification:#{current_user.email}"

    if Rails.cache.exist?(cache_key)
      redirect_to settings_email_path, notice: I18n.t('flash.email_verification_time_limit')
    else
      Rails.cache.write(cache_key, true, expires_in: 1.minute)
      UserMailer.with(user: current_user).email_verification.deliver_later
      redirect_to settings_email_path, notice: I18n.t('flash.email_verification_sent')
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :current_password, account_attributes: [:path])
  end
end
